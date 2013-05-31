# Dependencies
Backbone = require '../solutionio-backbone'
List = require '../cayasso-list'
Main = require '../main/'
Model = require '../model/'
_ = require '../underscore/'

exports.EventsList = Backbone.View.extend

  mainTemplate: require('./events-list')

  initialize: ->
    @eventlist = new Model.EventList()
    @eventlist.fetch()
    @.render()

  render: ->

    @$el.html _.template(@mainTemplate(), this)

    return this


