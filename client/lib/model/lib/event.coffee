Backbone = require '../../solutionio-backbone'

exports.Event = Backbone.Model.extend
  idAttribute: "eventId"

  url: ->
    base = 'event'
    if @isNew()
      return base
    base + '/' + @idAttribute
