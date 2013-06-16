Backbone = require '../solutionio-backbone'
moment   = require '../moment'

exports.EventView = EventView = Backbone.View.extend

  template: require './event-view'

  initialize: ->
    @model.getComments => @render()
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
          commentURL: @commentURL
          subscribed: isSubscribed
    else  
      @$el.html @template
        model: @model
        loggedIn: false
        comments: @model.get('comments')
        commentURL: @commentURL
    

    @$el.find('ul.tags li a').each (index, el)->
      $(el).click ->
        App.Router.navigate "/events/tagged/#{$(el).attr('data-tag')}", 
          replace: true
          trigger: true
        return false

    console.log @$('.subscribeBtn')
    console.log @$el.find('.randomThing')  
    @$el.find('.subscribeBtn').on "click",  =>
    
  events:
    'click button': (e) ->
      @subscribe()

    @$el.find('.addComment').click =>
      @addComment()

    @$el.find('.subscribe').click =>
      @subscribe()

    @$el.find('.delete').click =>
      @removeComment(this)

  removeComment: (element) ->
    # remove from the comments list
    # remove from the collection
    # synchronize the comments list

  addComment: ->
    id = @model.get('id')
    data =
      comment: @$el.find('.newComment').val()

    author = "Get logged in username"
    # Use backbone to push into the collection directly
    $.post @model.commentsUrl(), data, =>
      @insertComment data.comment, author, moment().unix()

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
      if @subscribed # Subscribes to the event
        App.Auth.authPost("/api/event/#{@model.get('id')}/subscribe")
      else # Unsubscribe from the event
        App.Auth.authPost("/api/event/#{@model.get('id')}/unsubscribe")

      $('#loading-indicator').show()

      $('#subscribeBtn').hide()

      @render()   

