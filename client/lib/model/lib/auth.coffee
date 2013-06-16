$        = require '../../component-jquery'
Backbone = require '../../solutionio-backbone'

exports.Auth = Backbone.Model.extend 
  authPost:  (url, data) ->
    console.log "url: #{url}"
    authData = 
      "userId": App.User.id
      "key": App.User.key
    if data
      dataPacket = _.extend authData, data
    else
      dataPacket = data
    console.log "dataPacket:", dataPacket
    $.post(url, dataPacket)
  authGet:  (url, callback) ->
    authData = 
      "userId": App.User.id
      "key": App.User.key
    $.get(url, authData, callback)

