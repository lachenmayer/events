Backbone        = require '../solutionio-backbone'

Model           = require '../model'
Events          = Model.Events
ICalURL         = Model.ICalURL
Tags            = Model.Tags
EventView       = require('../event-view').EventView
EventsListView  = require('../events-list').EventsListView
CreateEventView = require('../create-event-view').CreateEventView
LoginView       = require('../login-view').LoginView
TagListView     = require('../tag-list').TagListView
Strings         = require('../strings').lang 'en'
NotFoundView    = require('../not-found').NotFoundView
FirstTimeView   = require('../firstTime-view').FirstTimeView
feeds           = require('../feed-view')

exports.Router = Backbone.Router.extend

  routes:
    ''                       : 'events'
    'events'                 : 'events'
    'event/new'              : 'createEvent'
    'event/:id'              : 'event'
    'events/tagged/:tag'     : 'taggedEvents'
    'events/subscribed'      : 'subscribedEvents'
    'firstTime'              : 'firstTime'
    'ical/subscribe/outlook' : 'outlook'
    'ical/subscribe/gmail'   : 'gmail'
    'tags'                   : 'tags'
    'login'                  : 'login'
    '*default'               : 'defaultRoute'


  gmail: ->
    App.GmailView ?= new feeds.GmailView
      model: new ICalURL
    @loadView App.GmailView, Strings.setupGmail

  outlook: ->
    console.log "Opening outlook"
    App.OutlookView ?= new feeds.OutlookView
      model: new ICalURL
    @loadView App.OutlookView, Strings.setupOutlook

  firstTime: ->
    App.FirstTimeView ?= new FirstTimeView
      model: new ICalURL
    @loadView App.FirstTimeView, Strings.firstTime

  createNewEventsList: ->
    App.EventsListView ?= new EventsListView
      collection: App.EventsList

  events: ->
    @createNewEventsList()
    @loadView App.EventsListView, Strings.upcomingEvents

  subscribedEvents: ->
    @createNewEventsList()
    @loadView App.EventsListView, Strings.upcomingEvents

  tags: ->
    App.TagList.setLoggedIn App.User.isLoggedIn()
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

  taggedEvents: (tagName)->
    taggedEvents = new Events
      tagName: tagName
    eventsView = new EventsListView
      collection: taggedEvents
      loadView = (view)=>
        @loadView eventsView, "'#{tagName}' Events", view

      if App.User.isLoggedIn()
        App.Auth.authGet "/api/tags/#{tagName}/isSubscribed/", (result)=>
          bview = eventsView.bottomBarView()
          bview.setSubscribed result?.subscribed?
        
          loadView bview
      else
        loadView null
  login: ->
    App.LoginView ?= new LoginView
    @loadView App.LoginView, Strings.loginViewTitle

  createEvent: ->
    createEventView = new CreateEventView()
    @loadView createEventView, Strings.newEvent

  defaultRoute: (route) ->
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

  loadView: (view, title, bottomBarView=null) ->
    return if App.NavBar.currentViewObject()?.url is window.location.pathname
    App.NavBar.pushViewObject
      view: view
      title: title
      url: window.location.pathname
    App.BottomBar.setContentView bottomBarView

  routeNotFound: ->
    App.NotFoundView ?= new NotFoundView()
    @loadView App.NotFoundView, Strings.notFoundTitle

