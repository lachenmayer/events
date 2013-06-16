Backbone = require '../../solutionio-backbone'
auth = require './auth'

exports.Event = Backbone.Model.extend
  url: ->
    base = '/api/event'
    if @isNew()
      return base
    base + '/' + @id
  isSubscribed: (id, callback) ->
    base = '/api/event' + '/' + id + '/isSubscribed'
    App.Auth.authGet base, (res) ->
      if not res.isSubscribed
      	callback false
      else
      	callback res.isSubscribed


  
