_         = require '../component-underscore'
Backbone  = require '../solutionio-backbone'

exports.NavBar = Backbone.View.extend

  viewObjects: []

  initialize: ->
    @$titleElement = @$el.find @options.title
    @$container = @$el.find @options.container
    @$accessoryButton = @$el.find @options.accessoryButton
    @$accessoryButton.on 'click', =>
      App.dispatcher.trigger 'navbar:accessoryButton'
    @$backButton = @$el.find @options.backButton
    @$backButton.on 'click', =>
      App.dispatcher.trigger 'navbar:backButton'
      @popViewObject()

  # Returns the visible view object (at the top of the stack)
  currentViewObject: ->
    return null unless @hasViews()
    @viewObjects[@viewObjects.length - 1]

  setRootViewObject: (viewObject) ->
    # Unbind the old view from .inner
    if @currentViewObject()?
      @currentViewObject.setElement(null)

    # Set the new stack of views
    @viewObjects = [viewObject]
    @render()

  hasViews: ->
    @viewObjects.length > 0

  pushViewObject: (viewObject) ->
    @viewObjects.push(viewObject)
    @render()

  popViewObject: ->
    return unless @hasViews()
    @viewObjects.pop()
    App.Router.navigate @currentViewObject().url,
      trigger: false
    @render()

  popToRootViewObject: ->
    return unless @hasViews()
    @viewObjects.splice 0, 1
    @render()

  updateContentView: ->
    if @$container and @currentViewObject()? and @currentViewObject().view?
      @currentViewObject().view.setElement(@$container).render()

  render: ->
    @$accessoryButton.hide()

    if @viewObjects.length > 1
      @$backButton.html '&larr;'
      @$backButton.show()
    else
      @$backButton.hide()

    if @currentViewObject()?
      @$titleElement.html @currentViewObject().title
      @updateContentView()

    this
