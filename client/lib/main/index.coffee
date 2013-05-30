Backbone = require('../solutionio-backbone');

exports.DocumentRow = Backbone.View.extend({
  initialize: ->
    this.$el.html(require('./main')());

  render: ->
#     this.$el.html(require())

});