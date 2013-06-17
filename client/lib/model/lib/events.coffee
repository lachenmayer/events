Backbone = require '../../solutionio-backbone'
Event    = require('./event').Event

exports.Events = Backbone.Collection.extend
  initialize: (options)->
    @tagName = options?.tagName 

  model: Event

  fetch: ->
    App.Auth.authGet @url(), (data) =>
      @reset data

  url: ->
    '/api/events'