_         = require '../underscore'
Backbone  = require '../solutionio-backbone'
Bacon     = require '../baconjs'

keyup = (elem) ->
  elem.asEventStream('keyup').map((e) -> $(e.currentTarget))

exports.LoginView = Backbone.View.extend

  loginTemplate: require './login'
  logoutTemplate: require './logout'

  render: ->
    action = if App.User.isLoggedIn() then 'logout' else 'login'
    @$el.html _.template this["#{action}Template"]()
    @submitButton = @$('input[type=submit]')
    this[action]()
    this

  login: ->
    @$('#login form').submit (e) =>
      e.preventDefault()
      @inputs =
        username: @$ '.username input'
        password: @$ '.password input'
      if @fieldsEmpty()
        @highlightIfEmpty()
        return
      {username, password} = @inputs
      App.User.login username.val(), password.val(), (err) =>
        if err?
          return @highlightAll()
        App.reloadPage()


  logout: ->
    @$('#logout form').submit (e) =>
      e.preventDefault()
      App.User.logout()
      App.reloadPage()

  fieldsEmpty: ->
    empty = false
    for field of @inputs
      input = @inputs[field]
      if input.val() is ''
        input.addClass 'error'
        empty = true
    empty

  highlightAll: ->
    for field of @inputs
      input = @inputs[field]
      input.addClass 'error'
      keyup(input).take(1).onValue (input) ->
        input.removeClass 'error'

  highlightIfEmpty: ->
    for field of @inputs
      currentValue = Bacon.once @inputs[field]
      empty = currentValue.merge(keyup(@inputs[field]))
                          .filter((input) -> input.val() is '')
      empty.onValue (input) ->
        nonempty = keyup(input).filter((input) -> input.val() isnt '').take(1)
        nonempty.onValue((input) -> input.removeClass 'error')
        input.addClass 'error'

