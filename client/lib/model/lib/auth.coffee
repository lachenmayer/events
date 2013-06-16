$        = require '../../component-jquery'
Backbone = require '../../solutionio-backbone'

exports.Auth = Backbone.Model.extend 
  authPost:  (url, data, callback) ->
    data["userId"] = App.User.id
    data["key"] = App.User.key
    console.log "data:", data
    $.post(url, data, callback)
  authGet:  (url, callback) ->
    authData = 
      "userId": App.User.id
      "key": App.User.key
    $.get(url, authData, callback)

