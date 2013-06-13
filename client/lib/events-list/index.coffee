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

  initialize: ->
    @dayLists = []
    @collection.bind 'reset', =>
      @splitEvents()
      @render()
    @collection.fetch()

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

  openEvent: (eventId) ->
    App.Router.navigate "/event/#{eventId}", true

  render: ->
    @$el.html _.template @mainTemplate
      days: @dayLists
    this

