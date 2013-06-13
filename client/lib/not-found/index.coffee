_         = require '../underscore'
Backbone  = require '../solutionio-backbone'

exports.NotFoundView = Backbone.View.extend
  mainTemplate: require './not-found'

  render: ->
    @$el.html _.template @mainTemplate()