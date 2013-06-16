Backbone = require '../../solutionio-backbone'

ICAL_RELOAD_URL = "/api/user/ical/url/reload"
ICAL_GET_URL    = "/api/user/ical/url"

exports.ICalURL = Backbone.Model.extend
  url: -> '/api/user/ical/url'

  reload: ->
    App.Auth.authGet ICAL_RELOAD_URL, (data) ->
      newId = data
      @set('icalId', newId)

  fetch: ->
    console.log "Fetchfunc"
    App.Auth.authGet ICAL_GET_URL, (data) =>
      console.log "Value", data
      @set 'icalId', data.icalId

  getIcalURL: (callback) ->
    icalId = @get('icalId')
    if icalId
      hostname = window.location.host
      return "http://#{hostname}/api/calendar/#{icalId}"
    else return ""
