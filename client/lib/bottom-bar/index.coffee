_               = require '../underscore'
Backbone        = require '../solutionio-backbone'

exports.BottomBar = Backbone.View.extend
  initialize: ->
    @contentView = null

  render: ->
    if @contentView? then @$el.show() else @$el.hide()

    if @$el and @contentView?
      @contentView.setElement(@$el).render()
    
  setContentView: (contentView)->
    @contentView = contentView
    @render()
    