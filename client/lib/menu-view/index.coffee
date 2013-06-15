_           = require '../component-underscore'
Backbone    = require '../solutionio-backbone'
{LoginView} = require '../login-view'

exports.MenuView = Backbone.View.extend

  mainTemplate: require './menu-view'

  render: ->
    @$el.html _.template @mainTemplate()
    loginView = new LoginView
      el: @$('.login')
    loginView.render()

