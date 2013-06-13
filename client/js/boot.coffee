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
  $('body').animate
    'scrollTop': 0
  $(window).scroll ->
    if $('body').scrollTop() > 0
      $('#navbar').addClass('shadow')
    else
      $('#navbar').removeClass('shadow')

  App.NavBar = new NavBar
    title: '#navbar h1 .inner'
    backButton: '#navbar a#back'
    accessoryButton: '#navbar a#accessory-button'
    helperView: '#helper-view'
    container: '#main-view'
    el: $('#content')
  App.NavBar.render()

  App.EventsList = new Events
  App.TagList = new Tags

  App.EventsListView = new EventsListView
    collection: App.EventsList

  App.NavBar.setRootViewObject
    view: App.EventsListView
    title: Strings.upcomingEvents
    url: '/'

  App.Router = new Router
  Backbone.history.start
    pushState: true

