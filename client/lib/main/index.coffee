_         = require '../component-underscore'
Backbone  = require '../solutionio-backbone'
jade      = require '../jade-runtime'
NavBar    = require('../navbar').NavBar

exports.MainView = Backbone.View.extend
  title: 'Events'
  mainTemplate: require './main'

  initialize: ->
    App.dispatcher.on 'setTitle', (title) =>
        @title = title
        @render()
    App.NavBar = new NavBar
      title: '#navbar h1'     # Selector for the title element
      backButton: '#navbar a'
      container: '#main-view .inner'

  setContentViewObject: (viewObject)->
    App.NavBar.setRootViewObject viewObject

  render: ->
    # Render the main template
    @$el.html @mainTemplate
      title: @title
    App.NavBar.setElement $('#app')
    App.NavBar.render()
    this

