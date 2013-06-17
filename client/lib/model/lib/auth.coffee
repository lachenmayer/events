$        = require '../../component-jquery'
Backbone = require '../../solutionio-backbone'

exports.Auth = Backbone.Model.extend 
  authPost:  (url, data, callback) ->
    if not data
      data = {}
    data["userId"] = App.User.id
    data["key"] = App.User.key
    $.post(url, data, callback)
  authGet:  (url, callback) ->
    if App.User.isLoggedIn()
      authData =
        "userId": App.User.id
        "key": App.User.key
    else
      authData = {}
    $.get(url, authData, callback)

