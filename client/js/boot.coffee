window.$ = window.jQuery = require 'component-jquery'
Backbone       = require 'solutionio-backbone'
EventsListView = require('events-list').EventsListView
_              = require 'component-underscore'

# Store our stuff in a global app object.
window.App =
  dispatcher: _.clone Backbone.Events

# Set up the main view
$ ->
  # hide iOS browser chrome
  window.top.scrollTo(0, 1)

  Main = require 'main'

  App.MainView = new Main.MainView
    el: $('#content')
  App.MainView.render()

  # Set the Events List as the content view
  App.EventsListView = new EventsListView()
  App.MainView.setContentViewObject
    view: App.EventsListView
    title: 'Upcoming Events'
    
  App.NavBar.pushViewObject
    view: null
    title: 'Hello'

