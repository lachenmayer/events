Backbone = require '../../solutionio-backbone'

exports.Event = Backbone.Model.extend
  url: ->
    base = 'event'
    if @isNew()
      return base
    base + '/' + @id
