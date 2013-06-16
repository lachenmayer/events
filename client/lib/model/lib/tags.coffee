Backbone = require '../../solutionio-backbone'

exports.Tags = Backbone.Collection.extend
  url: 'api/tags/ALL'
  
  setLoggedIn: (loggedIn)->
    @loggedIn = loggedIn
    @fetch()
    
  fetch: (options)->
    return Backbone.Collection.prototype.fetch.call(this, options) unless @loggedIn
    
    App.Auth.authGet '/api/user/tags', (json)=>
      console.log json
    
      @reset json
