express = require 'express'
eventDiscoveryAPI = require 'eventDiscovery'

app = express()

PORT = 5278

app.use express.compress()
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser()

app.use express.session secret: 'alex is cool'
app.use express.logger 'dev'

app.listen PORT, ->
  console.log "running! on port #{PORT}"

app.get '/eventdiscovery', eventDiscoveryAPI.all

