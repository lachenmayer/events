# Set up dependencies.
window.$ = window.jQuery = require('component-jquery');
Backbone = require('solutionio-backbone');

# Store our stuff in a global app object.
App = {
};

# Set up the main view
$(->
  Main = require('main')
  
  App.MainWindow = new Main.MainView({
    el: $('#content')
  })
)
