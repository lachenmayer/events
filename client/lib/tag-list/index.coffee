Backbone = require '../solutionio-backbone'
List = require '../cayasso-list'

exports.TagListView = Backbone.View.extend
  mainTemplate: require './tag-list'
  
  initialize: ->
    App.dispatcher.on 'sort_options:change', (id, index)=>
      sort_options = $('#tagsort li a')
      sort_options.removeClass('selected')
      sort_options.eq(index).addClass('selected')

      switch id
        when "alphabetically"
          @list.sort 'name',
            asc: true
        when "popularity"
          @list.sort 'numEvents',
            desc:true

  render: ->
    @$el.html @mainTemplate
      tags: @collection
    
    $('#tagsort li a').each (index, el)->
      $(el).click ->
        App.dispatcher.trigger 'sort_options:change', $(el).parent().attr('class'), index
      
    @list = new List 'taglist',
      valueNames: [
        'name',
        'checked'
        'numEvents'
      ]