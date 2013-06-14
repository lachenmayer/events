Backbone = require '../../solutionio-backbone'

exports.Events = Backbone.Collection.extend
  initialize: (options)->
    @tagName = options?.tagName

  url: ->
    base = '/api/events'
    
    return if @tagName? then "#{base}/tagged/#{@tagName}" else base
