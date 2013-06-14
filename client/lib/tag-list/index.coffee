Backbone = require '../solutionio-backbone'
_        = require '../underscore'
List     = require '../cayasso-list'

TagView = Backbone.View.extend
  mainTemplate: require './tag-item'

  initialize: ->
    @render()

  render: ->
    name    = @model.get('tagName')
    checked = @model.get('subscribed')

    @$el.html _.template @mainTemplate
      name: name

    li = @$el.find('li')

    if (checked)
      li.addClass 'checked'
    else
      li.removeClass 'checked'

    li.click =>
      @check()

  check: ->
    @model.set('subscribed', !@model.get('subscribed'))
    name = if @model.get('subscribed') then 'subscribe' else 'unsubscribe'
    tagId = @model.get('id')
    $.get("/api/tags/#{tagId}/#{name}")
    @render()

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
