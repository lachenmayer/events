_         = require '../underscore'
Backbone  = require '../solutionio-backbone'

exports.LoginView = Backbone.View.extend

  loginTemplate: require './login'
  logoutTemplate: require './logout'

  render: ->
    action = if App.User.isLoggedIn() then 'logout' else 'login'
    @$el.html _.template this["#{action}Template"]()
    this[action]()
    this

  login: ->
    @$('#login form').submit (e) =>
      e.preventDefault()
      inputs = [@$el.find('.username input'),
                @$el.find('.password input')]
      @highlight inputs
      [username, password] = (field.val() for field in inputs)
      App.User.login username, password, (err) ->
        unless err
          console.log "logged in: #{App.User.isLoggedIn()}"

  logout: ->
    @$('#logout form').submit (e) =>
      e.preventDefault()
      App.User.logout()

  highlight: (fields) ->
    for field in fields
      field.toggleClass 'error', (field.val() is '')

