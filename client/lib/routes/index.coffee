Backbone       = require '../solutionio-backbone'

Model          = require '../model'
EventsListView = require('../events-list').EventsListView
eventView      = require '../event-view'

exports.Router = Backbone.Router.extend

  routes:
    ''          : 'eventsList'
    'event/:id' : 'eventView'

  eventsList: ->
    App.EventsListView ?= new EventsListView()
    App.MainView.setContentViewObject
      view: App.EventsListView
      title: 'Upcoming Events'


  eventView: (id) ->
    event = new Model.Event
      id: id
    event.fetch()
    eventView.loadView event
