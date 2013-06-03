# Dependencies
Backbone = require '../solutionio-backbone'
List     = require '../cayasso-list'
moment   = require '../moment'
_        = require '../underscore/'

Main     = require '../main/'
Model    = require '../model/'

exports.EventsListView = Backbone.View.extend

  mainTemplate: require './events-list'

  initialize: ->
    @eventsList = new Model.Events()
    @eventsList.bind 'reset', =>
      @splitEvents()
      @render()
    @eventsList.fetch()

  # separate events list into a list for each day
  splitEvents: ->
    days = []
    newDay = (date) ->
      date: date
      events: []
    day = newDay moment()
    @eventsList.each (e) ->
      eventDate = moment.unix e.get 'date'
      unless eventDate.isSame day.date, 'day'
        days.push day if day.events.length > 0
        day = newDay eventDate
      day.events.push e
    days

  render: ->
    @$el.html _.template @mainTemplate
      days: @splitEvents()
    this

