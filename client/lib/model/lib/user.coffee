$        = require '../../component-jquery'
Backbone = require '../../solutionio-backbone'
store    = require '../../store'

UserInfo = Backbone.Model.extend
  url: ->
    "/api/user/info/#{@attributes.username}"

exports.User = Backbone.Model.extend

  initialize: ->
    user = store 'User'
    if user?
      this[key] = user[key] for key of user

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
      @storeInfo username, data.id, data.key, ((err) -> fn? err)

  validLogin: (data) ->
    data.key? and data.id?

  logout: ->
    @clearInfo()

  storeInfo: (@username, @id, @key, fn) ->
    userInfo = new UserInfo
      username: username
    onFetch = (info) =>
      @userInfo = info.attributes
      store 'User',
        username: username
        id: id
        key: key
        userInfo: info.attributes
      fn? null
    userInfo.fetch
      success: onFetch

  clearInfo: ->
    store 'User', null
    @username = @id = @key = null

