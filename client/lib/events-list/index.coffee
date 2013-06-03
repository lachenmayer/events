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

  render: ->
    @$el.html _.template @mainTemplate
      days: @dayLists
    this

