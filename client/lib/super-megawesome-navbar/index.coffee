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
    @render
    
  updateContentView: ->
    @currentViewObject().view.setElement(@$container).render() if @currentViewObject()?
    
  updateElements: ->
    @$titleElement = @$el.find @options.title
    @$backButton = @$el.find @options.backButton
    @$container = @$el.find @options.container
    
  setElement: (el)->
    Backbone.View.prototype.setElement.call(this, el)
    
    @updateElements()

  render: ->
    return if !@currentViewObject()?
    
    if @numberOfViewObjects() > 1
      @$backButton.html @viewObjects[@viewObjects.length - 2].title
      @$backButton.show()
    else
      @$backButton.hide()
  
    @$titleElement.html @currentViewObject().title
    @updateContentView()
    
    this