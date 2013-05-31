Backbone = require('../solutionio-backbone')

exports.MainView = Backbone.View.extend({
  initialize: ->
    this.$el.html(require('./main')())
    
    EventList = require('../events-list')
    
    container = this.$el.find('.inner')
    
    list = new EventList.EventsList({
      el: container
    })

  render: ->
#     this.$el.html(require())

});