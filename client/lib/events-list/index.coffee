# Dependencies
Backbone  = require '../solutionio-backbone'
List      = require '../cayasso-list'
moment    = require '../moment'
_         = require '../underscore/'

Main      = require '../main/'
Model     = require '../model/'
EventView = require('../event-view/').EventView

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
    @eventsList = new Model.Events()
    @dayLists = []
    @eventsList.bind 'reset', =>
      @splitEvents()
      @render()
    @eventsList.fetch()

  # separate events list into a list for each day
  splitEvents: ->
    @dayLists = []
    newDay = (date) ->
      date: date
      events: []
    day = newDay moment()
    @eventsList.each (e) =>
      eventDate = moment.unix e.get 'date'
      unless eventDate.isSame day.date, 'day'
        @dayLists.push day if day.events.length > 0
        day = newDay eventDate
      day.events.push e

  openEvent: (eventId) ->
    event = @eventsList.get eventId
    eventView = new EventView
      model: event
    App.NavBar.pushViewObject
      view: eventView
      title: event.get 'name'

  render: ->
    @$el.html _.template @mainTemplate
      days: @dayLists
    this

