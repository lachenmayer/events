Backbone = require('../solutionio-backbone')
List = require('../cayasso-list')

exports.EventsList = Backbone.View.extend({
  render: ->
    @$el.html(require('./events-list')())
    
    return this

});