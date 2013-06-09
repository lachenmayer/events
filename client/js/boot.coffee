window.$ = window.jQuery = require 'component-jquery'
Backbone       = require 'solutionio-backbone'
_              = require 'component-underscore'

EventsListView = require('events-list').EventsListView
TagListView    = require('tag-list').TagListView
Router         = require('routes').Router
NavBar         = require('navbar').NavBar
Events         = require('model').Events
Tags           = require('model').Tags
Strings        = require('strings').lang 'en'

# Store our stuff in a global app object.
window.App =
  dispatcher: _.clone Backbone.Events
  language: 'en'

# Set up the main view
$ ->
  # hide iOS browser chrome
  window.top.scrollTo(0, 1)

  App.NavBar = new NavBar
    title: '#navbar h1 .inner'
    backButton: '#navbar a#back'
    accessoryButton: '#navbar a#accessory-button'
    container: '#main-view .inner'
    el: $('#content')
  App.NavBar.render()

  App.EventsList = new Events
  App.TagList = new Tags

  App.EventsListView = new EventsListView
    collection: App.EventsList
    
  App.TagListView = new TagListView
    collection: App.TagList

  App.dispatcher.on 'navbar:backButton', =>
    App.Router.navigate '/', true

  App.Router = new Router
  Backbone.history.start
    pushState: true

