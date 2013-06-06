window.$ = window.jQuery = require 'component-jquery'
Backbone       = require 'solutionio-backbone'
_              = require 'component-underscore'

EventsListView = require('events-list').EventsListView
Router         = require('routes').Router
NavBar         = require('navbar').NavBar
Events         = require('model').Events
Strings        = require('strings').lang 'en'
Events         = require('model').Events

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

  App.EventsListView = new EventsListView
    collection: App.EventsList
    
  tags = [
      "name": "Campaigns"
      "numEvents": 20
    ,
      "name": "Entertainments"
      "numEvents": 40
    ,
      "name": "Freshers' Events"
      "numEvents": 15
    ,
      "name": "Social & Recreational"
      "numEvents": 65
    ,
      "name": "Guest Lecture"
      "numEvents": 10
    ,
      "name": "Union Meetings"
      "numEvents": 25
    ,
      "name": "Music, Drama & Dance"
      "numEvents": 17
    ,
      "name": "Sport"
      "numEvents": 50
  ]
    
  App.TagListView = new TagListView
    collection: tags

  App.NavBar.setRootViewObject
    view: App.EventsListView
    title: Strings.upcomingEvents

  App.dispatcher.on 'navbar:backButton', =>
    App.Router.navigate '/', true

  App.Router = new Router
  Backbone.history.start
    pushState: true

