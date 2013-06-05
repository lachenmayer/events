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

  # Returns the visible view object (at the top of the stack)
  currentViewObject: ->
    if @viewObjects.length > 0
      @viewObjects[@viewObjects.length - 1]
    else
      null

  setRootViewObject: (viewObject) ->
    # Unbind the old view from .inner
    if @currentViewObject()?
      @currentViewObject.setElement(null)

    # Set the new stack of views
    @viewObjects = [viewObject]
    @render()

  pushViewObject: (viewObject) ->
    @viewObjects.push(viewObject)
    @render()

  popViewObject: ->
    return if @viewObjects.length <= 1
    @viewObjects.pop()
    @render()

  popToRootViewObject: ->
    return if @viewObjects.length <= 1
    @viewObjects.splice 0, 1
    @render()

  updateContentView: ->
    if @$container and @currentViewObject()? and @currentViewObject().view?
      @currentViewObject().view.setElement(@$container).render()

  render: ->
    @$accessoryButton.hide()

    if @viewObjects.length > 1
      @$backButton.html '&larr;' #@viewObjects[@viewObjects.length - 2].title
      @$backButton.show()
    else
      @$backButton.hide()

    if @currentViewObject()?
      @$titleElement.html @currentViewObject().title
      @updateContentView()

    this
