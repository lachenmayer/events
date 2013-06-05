Backbone        = require '../solutionio-backbone'

exports.CreateEventView = Backbone.View.extend

  template: require './create-event-view'

  initialize: ->
    console.log 'new event'

  render: ->
    @$el.html @template

