window.$ = window.jQuery = require 'component-jquery'
Backbone                 = require 'solutionio-backbone'
_                        = require 'component-underscore'

{EventsListView}         = require 'events-list'
{TagListView}            = require 'tag-list'
{MenuView}               = require 'menu-view'
{Router}                 = require 'routes'
{NavBar}                 = require 'navbar'
{Events, Tags, User}     = require 'model'
Strings                  = require('strings').lang 'en'

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
    accessoryTitle: 'Menu'
  App.NavBar.render()

  App.dispatcher.on 'navbar:accessoryButton', ->
    App.MenuView ?= new MenuView()
    if App.NavBar.isHelperViewVisible()
      App.NavBar.hideHelperView()
    else
      App.NavBar.showHelperView App.MenuView

  App.EventsList = new Events
  App.TagList = new Tags
  App.User = new User

  App.EventsListView = new EventsListView
    collection: App.EventsList

  App.NavBar.setRootViewObject
    view: App.EventsListView
    title: Strings.upcomingEvents
    url: '/'

  App.Router = new Router
  Backbone.history.start
    pushState: true

  App.reloadPage = ->
    App.Router.navigate window.location.pathname,
      trigger: true
      replace: true
    App.MenuView.render()

