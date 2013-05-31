# set up dependencies
Backbone = require('../solutionio-backbone')
jade = require('../jade-runtime')
_ = require('../component-underscore')

exports.MainView = Backbone.View.extend({
  title: "Events"
  mainTemplate: require('./main')
  
  initialize: ->
    App.dispatcher.on('setTitle', (title) ->
      @title = title
      @.render()
    , this)

  setContentView: (view) ->  
    # Unbind the old view from .inner
    if @contentView
      @contentView.setElement(null)
    
    # Set the new view
    @contentView = view
    @.render()

  # Puts 'view' in the element returned by $(selector)
  assignViewElement: (view, selector) ->
    if @contentView
      view.setElement(@$(selector)).render()

    
  render: ->
    # Render the main template
    @$el.html(@mainTemplate(
      title: @title
    ))
    
    # Render the content view into .inner
    @.assignViewElement(@contentView, '.inner')
      
    return this
  

});