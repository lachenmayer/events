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

    el = @$el.find('.resetURL')
    el.click =>
      if not el.hasClass 'disabled'
        el.addClass 'disabled'
        url = "/api/user/ical/url/reload/"
        App.Auth.authGet url, (data) =>
          @model.set 'icalId', data
          el.removeClass 'disabled'
      return false