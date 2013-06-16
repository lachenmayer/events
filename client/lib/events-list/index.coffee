# Dependencies
Backbone  = require '../solutionio-backbone'
moment    = require '../moment'
_         = require '../underscore'
jade      = require '../monstercat-jade-runtime'

Model     = require '../model'
Strings   = require('../strings').lang 'en'
eventView = require '../event-view'

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

  filterData: (string) -> (event) ->
    # More powerful data filtering here
    return string == '' ||
    event.get('name').toLowerCase().indexOf(string.toLowerCase()) != -1 ||
    event.get('location').toLowerCase().indexOf(string.toLowerCase()) != -1

  setFilter: (string) ->
    @filter = string
    @displayEvents()

  filterText: ->
    text = @$el.find('.filter').val()
    @setFilter text

  displayEvents: ->
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
  
  setSubscribed: (subscribed)->
    @subscribed = subscribed
    @render()
  
  render: ->  
    @$el.html _.template @bottomBar
      subscribed: @subscribed
    this

