Backbone = require '../../solutionio-backbone'

exports.Tag = Backbone.Model.extend
  url: ->
    base = '/api/tag'
    if @isNew()
      return base
    base + '/' + @id