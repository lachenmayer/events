window.$ = window.jQuery = require 'component-jquery'
Backbone       = require 'solutionio-backbone'
EventsListView = require('events-list').EventsListView
_              = require 'component-underscore'

Main = require 'main'
Router = require('routes').Router

# Store our stuff in a global app object.
window.App =
  dispatcher: _.clone Backbone.Events

# Set up the main view
$ ->
  # hide iOS browser chrome
  window.top.scrollTo(0, 1)

  App.MainView = new Main.MainView
    el: $('#content')
  App.MainView.render()

  App.Router = new Router
  Backbone.history.start
    pushState: true

