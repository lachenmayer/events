_        = require '../underscore'
Backbone = require '../solutionio-backbone'

exports.FirstTimeView = Backbone.View.extend
  mainTemplate: require './firstTime'

  initialize: ->
    @model.bind 'change', => @render()
    @model.fetch()

  render: ->
    # Might be helpful to know the newly created ical url and rss url
    @$el.html _.template @mainTemplate
      url: @model.getIcalURL()
      rssUrl: "url2"