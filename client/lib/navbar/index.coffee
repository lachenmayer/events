_         = require '../component-underscore'
Backbone  = require '../solutionio-backbone'

exports.NavBar = Backbone.View.extend

  viewObjects: []

  elems: [
    'title'
    'container'
    'accessoryButton'
    'backButton'
    'helperView'
  ]

  initialize: ->
    for elem in @elems
      this["$#{elem}"] = @$el.find @options[elem]
    @accessoryTitle = @options.accessoryTitle
    @$accessoryButton.on 'click', =>
      App.dispatcher.trigger 'navbar:accessoryButton'
    @$backButton.on 'click', =>
      App.dispatcher.trigger 'navbar:backButton'
      @popViewObject()
    @$helperView

  setAccessoryTitle: (title)->
    @accessoryTitle = title
    @render()

  # Returns the visible view object (at the top of the stack)
  currentViewObject: ->
    return null unless @hasViews()
    @viewObjects[@viewObjects.length - 1]

  setRootViewObject: (viewObject) ->
    if @currentViewObject()?
      @removeCurrentViewElement()
    @viewObjects = [viewObject]
    @render()

  hasViews: ->
    @viewObjects.length > 0

  pushViewObject: (viewObject) ->
    @removeCurrentViewElement()
    @viewObjects.push viewObject
    @render()

  popViewObject: ->
    return unless @hasViews()
    @removeCurrentViewElement()
    @viewObjects.pop()
    App.Router.navigate @currentViewObject().url,
      trigger: false
    @render()

  popToRootViewObject: ->
    return unless @hasViews()
    @removeCurrentViewElement()
    @viewObjects.splice 0, 1
    @render()

  updateContentView: ->
    if @$container and @currentViewObject()?.view?
      @currentViewObject().view.setElement(@$container).render()

  showHelperView: (view) ->
    @helperView = view
    view.setElement(@$helperView).render()

  hideHelperView: ->
    @helperView = null
    @$helperView.hide()

  removeCurrentViewElement: ->
    @currentViewObject().view.setElement null

  render: ->
    if @accessoryTitle?
      @$accessoryButton.html @accessoryTitle
    else
      @$accessoryButton.hide()
  
    if @viewObjects.length > 1
      @$backButton.html '&larr;'
      @$backButton.show()
    else
      @$backButton.hide()

    if @currentViewObject()?
      @$title.html @currentViewObject().title
      @updateContentView()

    this
