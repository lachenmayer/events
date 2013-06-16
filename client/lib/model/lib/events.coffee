Backbone = require '../../solutionio-backbone'
Event    = require('./event').Event

exports.Events = Backbone.Collection.extend
  initialize: (options)->
    @tagName = options?.tagName 

  model: Event

  url: ->
    base = '/api/events'
    return if @tagName? then "#{base}/tagged/#{@tagName}" else base
