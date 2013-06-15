Backbone = require '../solutionio-backbone'

exports.EventView = EventView = Backbone.View.extend

  template: require './event-view'

  initialize: ->
    @model.bind 'change', =>
      @render()

  render: ->
    return unless @model.get('name')?
    @$el.html @template
      model: @model
      comments: @model.get('comments')
      
    @$el.find('ul.tags li a').each (index, el)->
      $(el).click ->
        App.Router.navigate "/events/tagged/#{$(el).attr('data-tag')}", 
          replace: true
          trigger: true
        return false

    @$el.find('.subscribe').click =>
      @subscribe()

  subscribe: ->
    if App.User.isLoggedIn()
      subButton  = @$el.find('.subscribe')
      subscribed = !subButton.hasClass('on')
      @model.set 'subscribed', subscribed
      if subscribed # Subscribes to the event
        App.Auth.authPost("/api/event/#{@model.get('id')}/subscribe")
      else # Unsubscribe from the event
        App.Auth.authPost("/api/event/#{@model.get('id')}/unsubscribe")
      @render()

