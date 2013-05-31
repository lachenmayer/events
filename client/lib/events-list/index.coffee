Backbone = require('../solutionio-backbone')
List = require('../cayasso-list')

exports.EventsList = Backbone.View.extend({
  initialize: ->
    @$el.html(require('./events-list')());
    
    options =
      valueNames: [ 'event-name', 'description' ]
    @list = new List('events-list', options)
    
    for i in [1..100]
      @list.add(
        'event-name': "Super-awesome event " + i
        'description': "Bacon ipsum dolor sit amet t-bone jowl anim et consequat irure. Chuck filet mignon laboris, in adipisicing irure capicola. Minim short loin hamburger jerky, est sirloin kielbasa. Ex tempor doner, occaecat ham quis ullamco. Sint jowl dolore short ribs elit sausage t-bone fatback chuck. Irure ut prosciutto ea sunt, elit dolore incididunt anim nostrud."
      )

  render: ->
#     this.$el.html(require())

});