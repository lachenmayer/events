coffeeScript  = require 'coffee-script'
express       = require 'express'
path          = require 'path'
routes        = require './app/routes'

app = express()

PORT = 5278

app.use express.compress()
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser()

app.use express.session secret: 'alex is cool'
app.use express.logger 'dev'

app.use '/js', express.static(path.join(__dirname,'/public/js'))
app.use '/css', express.static(path.join(__dirname, '/public/css'))
app.use '/img', express.static(path.join(__dirname, '/public/img'))

app.set 'view engine', 'jade'
app.set 'views', path.join(__dirname, "app/views")

routes app

app.listen PORT, ->
  console.log "running! on port #{PORT}"
