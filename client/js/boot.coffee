window.$ = window.jQuery = require 'component-jquery'
Backbone       = require 'solutionio-backbone'
EventsListView = require('events-list').EventsListView
_              = require 'component-underscore'

Router = require('routes').Router
NavBar = require('navbar').NavBar

# Store our stuff in a global app object.
window.App =
  dispatcher: _.clone Backbone.Events

# Set up the main view
$ ->
  # hide iOS browser chrome
  window.top.scrollTo(0, 1)

  App.NavBar = new NavBar
    title: '#navbar h1 .inner'
    backButton: '#navbar a#back'
    accessoryButton: '#navbar a#accessory-button'
    container: '#main-view .inner'

  App.NavBar.setElement $('#content')
  App.NavBar.render()

  App.EventsListView = new EventsListView()
  App.NavBar.setRootViewObject
    view: App.EventsListView
    title: 'Upcoming Events'

  App.Router = new Router
  Backbone.history.start
    pushState: true

