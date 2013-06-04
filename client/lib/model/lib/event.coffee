Backbone = require '../../solutionio-backbone'

exports.Event = Backbone.Model.extend
  url: ->
    base = '/api/event'
    if @isNew()
      return base
    base + '/' + @id
