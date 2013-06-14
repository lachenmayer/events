_         = require '../component-underscore'
Backbone  = require '../solutionio-backbone'

exports.MenuView = Backbone.View.extend
  mainTemplate: require './menu-view'

  render: ->
    @$el.html _.template @mainTemplate()