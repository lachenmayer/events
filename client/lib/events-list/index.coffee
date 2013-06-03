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
    @eventsList.each (e) ->
      date = moment.unix e.get 'date'
      console.log date.date()
    []

  render: ->
    @$el.html _.template @mainTemplate
      days: @splitEvents()
    this

