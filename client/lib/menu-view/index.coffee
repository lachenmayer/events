_           = require '../component-underscore'
Backbone    = require '../solutionio-backbone'
{LoginView} = require '../login-view'

exports.MenuView = Backbone.View.extend

  mainTemplate: require './menu-view'

  initialize: ->
    @loginView = new LoginView()

  render: ->
    @$el.html _.template @mainTemplate()
    @loginView.setElement(@$('.login')).render()

