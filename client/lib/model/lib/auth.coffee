$        = require '../../component-jquery'
Backbone = require '../../solutionio-backbone'

exports.Auth = Backbone.Model.extend 
  authPost:  (url) ->
    authData = 
      "userId": App.User.id
      "key": App.User.key
    $.post(url, authData)
  authGet:  (url, callback) ->
    console.log "AuthGet:", url, callback
    authData = 
      "userId": App.User.id
      "key": App.User.key
    $.get(url, authData, callback)

