$ = require '../../component-jquery'
Backbone = require '../../solutionio-backbone'
store = require '../../store'

exports.User = Backbone.Model.extend

  initialize: ->
    user = store 'User'
    if user?
      this[key] = user[key] for key of user
    @clearInfo()

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
      unless @validLogin data
        return fn? 'Invalid response'
      @storeInfo username, data.id, data.key
      fn? null

  validLogin: (data) ->
    data.key? and data.id?

  logout: ->
    @clearInfo()

  storeInfo: (@username, @id, @key) ->
    store 'User',
      username: username
      id: id
      key: key

  clearInfo: ->
    store 'User', null
    @username = @id = @key = null

