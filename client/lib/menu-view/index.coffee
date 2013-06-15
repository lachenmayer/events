_         = require '../component-underscore'
Backbone  = require '../solutionio-backbone'

exports.MenuView = Backbone.View.extend
  mainTemplate: require './menu-view'

  render: ->
    @$el.html _.template @mainTemplate()
    @onSubmit()

  onSubmit: ->
    @$el.find('form').submit (e) =>
      e.preventDefault()
      username = @$el.find('.username input').val()
      password = @$el.find('.password input').val()
      App.User.login username, password, (err) ->
        unless err
          console.log "logged in: #{App.User.isLoggedIn()}"
