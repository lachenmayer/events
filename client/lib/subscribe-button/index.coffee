_         = require '../component-underscore'
Backbone  = require '../solutionio-backbone'

exports.SubscribeButton = Backbone.View.extend
  mainTemplate: require './subscribe-button'

  initialize: ->
    @subscribed = @options?.subscribe
    
  setSubscribed: (subscribed)->
    console.log 'Here'
    
    if subscribed
      @$el.addClass('subscribed')
      @$el.find('.icon').addClass 'icon-check'
      @$el.find('.icon').removeClass 'icon-plus-sign-alt'
      @$el.find('span').html 'Subscribed'
    else
      @$el.removeClass('subscribed')
      @$el.find('.icon').removeClass 'icon-check'
      @$el.find('.icon').addClass 'icon-plus-sign-alt'
      @$el.find('span').html 'Subscribe'
  
  render: ->
    @$el.html _.template @mainTemplate
      subscribed: @subscribed