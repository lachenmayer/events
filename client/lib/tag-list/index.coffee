Backbone = require '../solutionio-backbone'
_        = require '../underscore'
List     = require '../cayasso-list'
{Auth}   = require '../model'

TagView = Backbone.View.extend
  mainTemplate: require './tag-item'

  initialize: ->
    @render()

  render: ->
    name      = @model.get('tagName')
    checked   = @model.get('subscribed')
    numEvents = @model.get('count')

    @$el.html _.template @mainTemplate
      name: name
      numEvents: numEvents

    li = @$el.find('li')

    if (checked)
      li.addClass 'checked'
    else
      li.removeClass 'checked'
      
    li.click =>
      @check li

  check: (el)->
    @model.set('subscribed', !@model.get('subscribed'))
    name = if @model.get('subscribed') then 'subscribe' else 'unsubscribe'
    tagId = @model.get('id')
    App.Auth.authGet("/api/tags/#{tagId}/#{name}")
    @setChecked el, true
    
  setChecked: (listEl, checked)->
    console.log listEl

    $e = listEl.find('.check')
    console.log $e
  
    if @model.get('subscribed')
      $e.removeClass 'icon-check-empty'
      $e.addClass 'icon-check'
    else
      $e.addClass 'icon-check-empty'
      $e.removeClass 'icon-check'


exports.TagListView = Backbone.View.extend

  mainTemplate: require './tag-list'

  initialize: ->
    @collection.bind 'reset', =>
      @render()
    App.dispatcher.on 'sort_options:change', (index)=>
      sortOptions = $('#tagsort li a')
      sortOptions.removeClass('selected')
      sortOptions.eq(index).addClass('selected')
      @sortTags()
    @collection.fetch()

  sortTags: ->
    sortType = $('#tagsort li a.selected').parent().attr('class')
    switch sortType
      when "alphabetically"
        @list.sort 'name',
          asc: true
      when "popularity"
        @list.sort 'numEvents',
          desc:true

  render: ->
    @$el.html _.template @mainTemplate
      tags: @collection
    $('#tagsort li a').each (index, el) ->
      $(el).click ->
        App.dispatcher.trigger 'sort_options:change', index

    @collection.each (tag) ->
      newItem = new TagView({model: tag})
      $('#taglist ul').append(newItem.$el)

    @list = new List 'taglist',
      valueNames: [
        'name'
        'checked'
        'numEvents'
      ]
    @sortTags()
