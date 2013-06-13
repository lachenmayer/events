Backbone        = require '../solutionio-backbone'

Model           = require '../model'
EventView       = require('../event-view').EventView
EventsListView  = require('../events-list').EventsListView
CreateEventView = require('../create-event-view').CreateEventView
LoginView       = require('../login-view').LoginView
TagListView     = require('../tag-list').TagListView
Strings         = require('../strings').lang 'en'
NotFoundView    = require('../not-found').NotFoundView

exports.Router = Backbone.Router.extend

  routes:
    ''          : 'events'
    'event/new' : 'createEvent'
    'event/:id' : 'event'
    'tags'      : 'tags'
    'login'     : 'login'
    '*default'  : 'default'

  events: ->
    App.EventsListView ?= new EventsListView
      collection: App.EventsList

  tags: ->
    App.TagListView ?= new TagListView
      collection: App.TagList
    @loadView App.TagListView, Strings.tags

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

  login: ->
    App.LoginView ?= new LoginView
    @loadView App.LoginView, Strings.loginViewTitle

  createEvent: ->
    createEventView = new CreateEventView()
    @loadView createEventView, Strings.newEvent

  default: (route) ->
    return if @removeTrailingSlash route
    
    @routeNotFound()

  removeTrailingSlash: (route) ->
    hasTrailingSlash = route[route.length-1] is '/'
    if hasTrailingSlash
      @navigate route[0...route.length-1],
        trigger: true
        replace: true
    hasTrailingSlash

  loadEventView: (event) ->
    eventView = new EventView
      model: event
    @loadView eventView, Strings.eventViewTitle

  loadView: (view, title) ->
    App.NavBar.pushViewObject
      view: view
      title: title
      url: window.location.pathname
      
  routeNotFound: ->
    App.NotFoundView ?= new NotFoundView()
    @loadView App.NotFoundView, Strings.notFoundTitle

