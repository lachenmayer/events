_         = require '../underscore'
Backbone  = require '../solutionio-backbone'

exports.LoginView = Backbone.View.extend
  mainTemplate: require './login'

  intialize: ->
  
  render: ->
    @$el.html _.template @mainTemplate()
    