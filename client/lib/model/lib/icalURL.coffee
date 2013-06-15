Backbone = require '../../solutionio-backbone'

ICAL_RELOAD_URL = "/api/user/ical/url/reload"

exports.ICalURL = Backbone.Model.extend
  url: -> '/api/user/ical/url'

  reload: ->
    $.get ICAL_RELOAD_URL, (data) ->
      newId = data
      @set('icalId', newId)

  getIcalURL: ->
    icalId = @get('icalId')
    if icalId
      hostname = window.location.host
      return "http://#{hostname}/api/calendar/#{icalId}"
    else return ""
