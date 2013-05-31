Backbone = require '../../solutionio-backbone'

exports.EventList = Backbone.Collection.extend({
  url: ->
    return 'events'
})