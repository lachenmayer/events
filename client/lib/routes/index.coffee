Backbone        = require '../solutionio-backbone'

Model           = require '../model'
EventView       = require('../event-view').EventView
EventsListView  = require('../events-list').EventsListView
CreateEventView = require('../create-event-view').CreateEventView
Strings         = require('../strings').lang 'en'

exports.Router = Backbone.Router.extend

  routes:
    ''          : 'events'
    'event/new' : 'createEvent'
    'event/:id' : 'event'

  events: ->
    App.EventsList.fetch()
    App.NavBar.popToRootViewObject()

  event: (id) ->
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

  createEvent: ->
    createEventView = new CreateEventView()
    @loadView createEventView, Strings.newEvent

  loadEventView: (event) ->
    eventView = new EventView
      model: event
    @loadView eventView, event.get('name')

  loadView: (view, title) ->
    App.NavBar.pushViewObject
      view: view
      title: title

