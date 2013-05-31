# Dependencies
Backbone = require '../solutionio-backbone'
List = require '../cayasso-list'
Main = require '../main/'
Model = require '../model/'

exports.EventsList = Backbone.View.extend({
  mainTemplate: require('./events-list')
  
  initialize: ->
    console.log(Main)
  
    new Model.Event()
  
  render: ->
    @$el.html @mainTemplate()
    
    return this

});