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
      @render()
    @eventsList.fetch()

  render: ->
    @$el.html _.template(@mainTemplate(), this)
    this

