$ = require '../../component-jquery'
Backbone = require '../../solutionio-backbone'

exports.User = Backbone.Model.extend

  initialize: ->
    @id = @key = null

  url: ->
    "/user/#{@id}"

  isLoggedIn: ->
    @validLogin this

  login: (username, password, fn) ->
    $.post '/api/user/login',
      username: username
      password: password
    , (data, status) =>
      if data.error?
        return fn? data.error
      if @validLogin data
        @id = data.id
        @key = data.key
      else
        fn? 'Invalid response'
      fn? null

  validLogin: (data) ->
    data.key? and data.id?

  logout: ->
    @id = @key = null

