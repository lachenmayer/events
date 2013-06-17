# Dependencies
Backbone  = require '../solutionio-backbone'
moment    = require '../moment'
_         = require '../underscore'
jade      = require '../monstercat-jade-runtime'

Model     = require '../model'
Strings   = require('../strings').lang 'en'
eventView = require '../event-view'
{SubscribeButton} = require '../subscribe-button'

moment.lang 'en',
  calendar:
    lastDay  : "[#{Strings.yesterday}]"
    sameDay  : "[#{Strings.today}]"
    nextDay  : "[#{Strings.tomorrow}]"
    lastWeek : Strings.dateFormat
    nextWeek : Strings.dateFormat
    sameElse : Strings.dateFormat

exports.EventsListView = Backbone.View.extend

  mainTemplate: require './events-list'
  daysTemplate: require './days'

  initialize: ->
    @filter = ''
    @tag = ''
    @subscribed = false
    @dayLists = []
    @collection.bind 'reset', =>
      @splitEvents()
      @loading = false
      @render()
    @collection.fetch()
    @loading = true

  events:
    'click tr': (e) ->
      @openEvent +e.currentTarget.className

  # separate events list into a list for each day
  splitEvents: ->
    @dayLists = []
    newDay = (date) ->
      date: date
      events: []
    day = newDay moment()
    
    @collection.each (e) =>
      return unless e.get 'name'
      eventDate = moment.unix e.get 'date'
      unless eventDate.isSame day.date, 'day'
        @dayLists.push day if day.events.length > 0
        day = newDay eventDate
      day.events.push e
    @dayLists.push day if day.events.length > 0

  openEvent: (eventId) ->
    App.Router.navigate "/event/#{eventId}", true

  applyFilter: (dayLists, f) ->
    filterEvent = (day) ->
      date: day.date
      events: (day.events.filter (event) -> f event)
    result = (filterEvent(day) for day in dayLists)

    result.filter (day) ->
      day.events.length > 0

  hasTag: (query, event, f) ->
    satisfying = event.get('tags').filter (tag) ->
      f query, tag
#      tag.toLowerCase().indexOf(query.substring(1)) != -1
    return satisfying.length > 0

  substrMatch: (query, value) ->
    value.toLowerCase().indexOf(query) != -1

  exactMatch: (query, value) ->
    query == value.toLowerCase()

  filterData: (string) -> (event) =>
    # More powerful data filtering here
    query = string.toLowerCase()
    if @subscribed && !event.get('subscribed')
      return false
    if @tag != '' && !@hasTag @tag.toLowerCase(), event, @exactMatch
      return false
    if query == '' || query == '@' || query == '#' || query == '+'
      return true
    if query[0] == '@'
      return @substrMatch query.substr(1), event.get('location')
    if query[0] == '#'
      return @substrMatch query.substr(1), event.get('name')
    if query[0] == '+'
      return @hasTag query.substr(1), event, @substrMatch
    return @substrMatch query, event.get('name') ||
           @substrMatch query, event.get('location')

  setSubscribedFilter: (value) ->
    @subscribed = value
    @displayEvents()

  setTagFilter: (string) ->
    @tag = string
    @displayEvents()

  setFilter: (string) ->
    @filter = string
    @displayEvents()

  filterText: ->
    text = @$el.find('.filter').val()
    @setFilter text

  displayEvents: ->
#     console.log @dayLists
  
    values = @applyFilter @dayLists, @filterData(@filter)
    
    @$el.find('#days').html _.template @daysTemplate
      days: values

  render: ->
    @$el.html _.template @mainTemplate
      loading: @loading
      noEvents: @dayLists?.length is 0
      filter: @filter

    @$el.find('.filter').keyup =>
      @filterText()

    @displayEvents()
    this
    
  bottomBarView: ->
    @bview = new exports.BottomBarView() unless @bview?
    @bview
    
exports.BottomBarView = Backbone.View.extend
  bottomBar: require './bottom-bar'
  
  initialize: ->
    @subscribed = @options?.subscribed
    @subscribeButton = new SubscribeButton()
  
  setSubscribed: (subscribed)->
    @subscribed = subscribed
    @render()
  
  render: ->  
    @$el.html _.template @bottomBar()
      
    $buttonEl = @$el.find('a.subscribe-button')
    @subscribeButton.setElement $buttonEl
    @subscribeButton.render()
    $buttonEl.click =>
      @subscribe()
    this

  subscribe: ->    
    if App.User.isLoggedIn()
      @subscribed = not @subscribed
      @subscribeButton.setSubscribed @subscribed
      
#       if @subscribed # Subscribes to the event
#         console.log "Unsubscribe"
#         App.Auth.authPost("/api/event/#{@model.get('id')}/subscribe")
#       else # Unsubscribe from the event
#         console.log "subscribe"
#         App.Auth.authPost("/api/event/#{@model.get('id')}/unsubscribe")

