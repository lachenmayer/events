Backbone       = require '../solutionio-backbone'

Model          = require '../model'
EventsListView = require('../events-list').EventsListView
eventView      = require '../event-view'

exports.Router = Backbone.Router.extend

  routes:
    'event/:id' : 'eventView'

  eventView: (id) ->
    event = new Model.Event
      id: id
    event.fetch()
    eventView.loadView event

