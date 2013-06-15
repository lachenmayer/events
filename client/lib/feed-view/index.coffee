_        = require '../underscore'
Backbone = require '../solutionio-backbone'

exports.FeedsView = Backbone.View.extend
  mainTemplate: require './feed'

  render: ->
    @$el.html _.template @mainTemplate
      rss:
        enabled: false
        tagCount: 10
      ical:
        enabled: false
        url: ''
      notifications: ""

exports.GmailView = Backbone.View.extend
  mainTemplate: require './gmail'

  initialize: ->
    @model.bind 'change', =>
      @render()
    @model.fetch()

  render: ->
    @$el.html _.template @mainTemplate
      url: @model.getIcalURL()

exports.OutlookView = Backbone.View.extend
  mainTemplate: require './outlook'

  initialize: ->
    @model.bind 'change', =>
      @render()
    @model.fetch()

  render: ->
    @$el.html _.template @mainTemplate
      url: @model.getIcalURL()