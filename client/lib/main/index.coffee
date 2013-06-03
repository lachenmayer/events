_         = require '../component-underscore'
Backbone  = require '../solutionio-backbone'
jade      = require '../jade-runtime'
NavBar    = require('../super-megawesome-navbar').NavBar

exports.MainView = Backbone.View.extend
  title: "Events"
  mainTemplate: require('./main')

  initialize: ->
    App.dispatcher.on 'setTitle', (title) =>
        @title = title
        @.render()
    App.NavBar = new NavBar
      title: '#navbar h1'     # Selector for the title element
      backButton: '#navbar a'
      container: '#main-view .inner'
      
  setContentView: (view)->
    App.NavBar.setRootViewObject
      view: view
      title: 'Hello'

  render: ->
    # Render the main template
    @$el.html @mainTemplate
      title: @title
    App.NavBar.setElement $('#app')
    App.NavBar.render()
    
    this

