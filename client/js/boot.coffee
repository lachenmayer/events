# Set up dependencies.
window.$ = window.jQuery = require('component-jquery')
Backbone = require('solutionio-backbone');
EventsList = require('events-list')
_ = require('component-underscore')

# Store our stuff in a global app object.
window.App =
  dispatcher: _.clone(Backbone.Events)

# Set up the main view
$(->
  Main = require('main')
  
  App.MainView = new Main.MainView({
    el: $('#content')
  })
  App.MainView.render()
  
  # Set the Events List as the content view
  App.EventsList = new EventsList.EventsList()
  App.MainView.setContentView(App.EventsList)
)
