_         = require '../component-underscore'
Backbone  = require '../solutionio-backbone'

exports.NavBar = Backbone.View.extend
  viewObjects: []

  initialize: ->
    @updateElements()

  # Returns the visible view object (at the top of the stack)
  currentViewObject: ->
    if @viewObjects.length > 0
      @viewObjects[@viewObjects.length - 1]
    else
      null

  numberOfViewObjects: ->
    @viewObjects.length

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
    return if @numberOfViewObjects() <= 1
    @viewObjects.pop()
    @render()

  updateContentView: ->
    if @$container and @currentViewObject()? and @currentViewObject().view?
      @currentViewObject().view.setElement(@$container).render()

  updateElements: ->
    @$titleElement = @$el.find @options.title
    @$backButton = @$el.find @options.backButton
    @$backButton.on 'click', =>
      @popViewObject()
    @$container = @$el.find @options.container
    @$accessoryButton = @$el.find @options.accessoryButton

  setElement: (el)->
    Backbone.View.prototype.setElement.call(this, el)
    @updateElements()

  render: ->
    @$accessoryButton.hide()

    if @numberOfViewObjects() > 1
      @$backButton.html @viewObjects[@viewObjects.length - 2].title
      @$backButton.show()
    else
      @$backButton.hide()

    if @currentViewObject()?
      @$titleElement.html @currentViewObject().title
      @updateContentView()

    this
