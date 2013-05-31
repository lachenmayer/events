# Dependencies
Backbone = require '../solutionio-backbone'
List = require '../cayasso-list'
Main = require '../main/'
Model = require '../model/'
_ = require '../underscore/'

exports.EventsList = Backbone.View.extend({
  mainTemplate: require('./events-list')
  
  initialize: ->
    @eventlist = new Model.EventList()
    @eventlist.fetch()
    @.render()
  
  render: ->
    console.log(@eventlist)
  
    @$el.html _.template(@mainTemplate(), this)
    
    return this

});