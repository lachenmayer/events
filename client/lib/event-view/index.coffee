Backbone = require '../solutionio-backbone'

exports.loadView = (event) ->
  eventView = new EventView
    model: event
  App.NavBar.pushViewObject
    view: eventView
    title: event.get 'name'


exports.EventView = EventView = Backbone.View.extend
  mainTemplate: require './event-view'

  initialize: ->
    @model.bind 'change', =>
      @render()

  render: ->
    return unless @model.get('name')?
    @$el.html @mainTemplate
      model: @model

