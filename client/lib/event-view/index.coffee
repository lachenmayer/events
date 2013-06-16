Backbone = require '../solutionio-backbone'
moment   = require '../moment'

{SubscribeButton} = require '../subscribe-button'

exports.EventView = EventView = Backbone.View.extend

  template: require './event-view'

  initialize: ->
    @model.getComments => @render()
    @model.bind 'change', =>
      @render()
    App.Event.isSubscribed @model.get('id'), (isSubscribed) =>
      @subscribed = isSubscribed
      @subscribeButton.setSubscribed isSubscribed
      
    @subscribeButton = new SubscribeButton()

  render: ->
    @$el.html @template
      model: @model
      comments: @model.get('comments')
      commentURL: @commentURL
      subscribed: @isSubscribed
      App.Event.isSubscribed @model.get('id'), (isSubscribed) =>
#         @subscribed = isSubscribed
#         @subscribeButton.setSubscribed @subscribed

    $buttonEl = @$el.find('a.subscribe-button')
    @subscribeButton.setElement  $buttonEl
    @subscribeButton.render()
    $buttonEl.click =>
      @subscribe()
    @$el.find('ul.tags li a').each (index, el)->
      $(el).click ->
        App.Router.navigate "/events/tagged/#{$(el).attr('data-tag')}", 
          replace: true
          trigger: true
        return false
    @$el.find('.insertComment').click =>
      @addComment()
    @$el.find('.addComment').submit =>
      @addComment()
  addComment: ->
    id = @model.get('id')
    data =
      comment: @$el.find('.newComment').val()

    author = App.User.username
    # Use backbone to push into the collection directly

    App.Auth.authPost @model.commentsUrl(), data, =>
      @insertComment data.comment, author, moment().unix()
    return false

  insertComment: (comment, author, added) ->
    newComment =
      comment: comment
      author: author
      createDate: added
    comments = @model.get('comments')
    comments.push newComment
    @model.set('comments', comments)
    @render()


  subscribe: ->
    if App.User.isLoggedIn()
      @subscribed = not @subscribed
      @subscribeButton.setSubscribed @subscribed
      
      if @subscribed # Subscribes to the event
        console.log "Unsubscribe"
        App.Auth.authPost("/api/event/#{@model.get('id')}/subscribe")
      else # Unsubscribe from the event
        console.log "subscribe"
        App.Auth.authPost("/api/event/#{@model.get('id')}/unsubscribe")


