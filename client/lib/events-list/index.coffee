# Dependencies
Backbone = require('../solutionio-backbone')
List = require('../cayasso-list')

exports.EventsList = Backbone.View.extend({
  mainTemplate: require('./events-list')

  render: ->
    @$el.html @mainTemplate()
    
    return this

});