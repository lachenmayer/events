# Dependencies
Backbone  = require '../solutionio-backbone'
List      = require '../cayasso-list'
moment    = require '../moment'
_         = require '../underscore'
jade      = require '../monstercat-jade-runtime'

Model     = require '../model'
eventView = require '../event-view'

moment.lang 'en',
  calendar:
    lastDay  : '[Yesterday]'
    sameDay  : '[Today]'
    nextDay  : '[Tomorrow]'
    lastWeek : 'dddd, MMMM Do'
    nextWeek : 'dddd, MMMM Do'
    sameElse : 'dddd, MMMM Do'

exports.EventsListView = Backbone.View.extend

  mainTemplate: require './events-list'

  events:
    'click tr': (e) ->
      @openEvent +e.currentTarget.className

  initialize: ->
    @dayLists = []
    @collection.bind 'reset', =>
      @splitEvents()
      @render()

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

