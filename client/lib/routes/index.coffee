Backbone       = require '../solutionio-backbone'

Model          = require '../model'
EventsListView = require('../events-list').EventsListView
eventView      = require '../event-view'

exports.Router = Backbone.Router.extend

  routes:
    ''          : 'eventsList'
    'event/:id' : 'eventView'

  eventsList: ->
    App.EventsList.fetch()

  eventView: (id) ->
    event = App.EventsList.get id
    unless event?
      event = new Model.Event
        id: id
      event.fetch
        success: (event) ->
          App.EventsList.add event
    eventView.loadView event

