Backbone = require '../solutionio-backbone'
_        = require '../underscore'
List     = require '../cayasso-list'

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
    
    $('#tagsort li a').each (index, el)->
      $(el).click ->
        App.dispatcher.trigger 'sort_options:change', index
      
    @list = new List 'taglist',
      valueNames: [
        'name',
        'checked'
        'numEvents'
      ]
      
    @sortTags()