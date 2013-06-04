Backbone = require '../solutionio-backbone'

exports.EventView = EventView = Backbone.View.extend
  mainTemplate: require './event-view'

  initialize: ->
    @model.bind 'change', =>
      @render()

  render: ->
    return unless @model.get('name')?
    @$el.html @mainTemplate
      model: @model

