Backbone       = require '../solutionio-backbone'

Model          = require '../model'
EventView      = require('../event-view').EventView
EventsListView = require('../events-list').EventsListView

exports.Router = Backbone.Router.extend

  routes:
    ''          : 'eventsList'
    'event/:id' : 'eventView'

  eventsList: ->
    App.EventsList.fetch()
    App.NavBar.popToRootViewObject()

  eventView: (id) ->
    event = App.EventsList.get id
    if event?
      @loadEventView event
    else
      event = new Model.Event
        id: id
      event.fetch
        success: (event) =>
          App.EventsList.add event
          @loadEventView event

  loadEventView: (event) ->
    eventView = new EventView
      model: event
    App.NavBar.pushViewObject
      view: eventView
      title: event.get 'name'

