Backbone = require '../solutionio-backbone'

exports.EventView = EventView = Backbone.View.extend

  template: require './event-view'

  initialize: ->
    @model.bind 'change', =>
      @render()

  render: ->
    return unless @model.get('name')?
    # Find out if the element has been subscribed to
    if App.User.isLoggedIn()
      App.Event.isSubscribed @model.get('id'), (isSubscribed) =>
        @subscribed = isSubscribed
        $('#loading-indicator').hide();
        $('#subscribeBtn').show()
        @$el.html @template
          model: @model
          loggedIn: true
          comments: @model.get('comments')
          subscribed: isSubscribed
    else  
      @$el.html @template
        model: @model
        loggedIn: false
        comments: @model.get('comments')
    
    @$el.find('ul.tags li a').each (index, el)->
      $(el).click ->
        App.Router.navigate "/events/tagged/#{$(el).attr('data-tag')}", 
          replace: true
          trigger: true
        return false
    
  events:
    'click button': (e) ->
      @subscribe()

  subscribe: ->
    if App.User.isLoggedIn()
      @subscribed = not @subscribed
      if @subscribed # Subscribes to the event
        App.Auth.authPost("/api/event/#{@model.get('id')}/subscribe")
      else # Unsubscribe from the event
        App.Auth.authPost("/api/event/#{@model.get('id')}/unsubscribe")

      $('#loading-indicator').show()

      $('#subscribeBtn').hide()

      @render()   

