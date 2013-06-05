express       = require 'express'
swagger       = require 'swagger-node-express'
swaggerModels = require './models'
eventData     = require './database/events'
userData      = require './database/users'
auth          = require './authenticate'
fs            = require 'fs'
http          = require 'http'
https         = require 'https'

server_options = {
key: fs.readFileSync('./cert/server.key'),
cert: fs.readFileSync('./cert/server.crt'),
requestCert: true
}

app = express()

HTTP_PORT  = 5278
HTTPS_PORT = 5279

app.use express.compress()
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser()

app.use express.session secret: 'alex is cool'
app.use express.logger 'dev'

swagger.setAppHandler app

swagger.addModels swaggerModels

returnJson = (res, field) -> (err, value) ->
  if err
    console.log "Error #{err}"
    throw swagger.errors.notFound(field)
  value = {} unless value?
  res.send JSON.stringify value

getUserByUsername =
  spec:
    decription: "Get the username by ID"
    path: "/user.json/{username}"
    notes: "Returns a username based on the given ID"
    summary: "Find username by ID"
    method: "GET"
    params: [swagger.pathParam("username", "username", "string")]
    responseClass: "user"
    errorResponses: [swagger.errors.invalid("username"), swagger.errors.notFound("user")]
    nickname: "getUserByUsername"

  action: (req, res) ->
    throw swagger.errors.invalid("username") unless req.params.username
    username = req.params.username
    userData.findUserByUsername username, (err, user) ->
      if err
        throw swagger.errors.notFound("user")
      else
        returnJson(res)(user)

getEventById =
  spec:
    description: "Get Event By Node ID"
    path: "/event.json/{eventId}"
    notes: "Returns an event based on ID"
    summary: "Find event by ID"
    method: "GET"
    params: [swagger.pathParam("eventId", "ID of event to be fetched", "long")]
    responseClass: "event"
    errorResponses: [swagger.errors.invalid("eventId"), swagger.errors.notFound("event")]
    nickname: "getNodeById"
  action: (req, res) ->
    throw swagger.errors.invalid("eventId") unless req.params.eventId
    id = parseInt(req.params.eventId)
    eventData.getEventById id, returnJson(res, "event")

getEventsInRange =
  spec:
    description: "Get Event In a given time range"
    path: "/event.json/findInRange"
    notes: "Returns a list of events"
    summary: "Find events within range"
    method: "GET"
    params: [
      swagger.params.query("eventRangeRequestHeader", "Event Range Request Header", "eventRangeRequestHeader", true, true, true, {})
      ]
    responseClass: "List[event]"
    errorResponses: [swagger.errors.invalid("eventRangeRequestHeader"), swagger.errors.notFound("events")]
    nickname: "getEventInRange"
  action: (req, res) ->
    console.log "Request Query", req.query
    throw swagger.errors.invalid("eventRangeRequestHeader") unless (\
      req.query.from \
      and req.query.to\
      and req.query.max\
      and req.query.offset)
    eventData.getEventsInRange req.query, returnJson(res, "events")

getAllEvents =
  spec:
    description: "Get all of the events"
    path: "/event.json/ALL"
    notes: "Returns all of the events saved in the database"
    method: "GET"
    params: []
    responseClass: "event"
    errorResponses: [swagger.errors.notFound("events")]
    nickname: "getAllEvents"
  action: (req, res) ->
    eventData.getAllEvents returnJson(res, "events")

userLogin =
  spec:
    description: "Check user is valid, provide a time-limited key to the user for authentication, key to user is 1->1 mapping"
    path: "/user/login"
    notes: "Login the user"
    method: "POST"
    params: []
    responseClass: "user"
    errorResponses: [swagger.errors.invalid("header"), swagger.errors.invalid("login")]
    nickname: "loginUser"
  action: (req, res) ->
    # Check what we exect is in the headers
    username = ""
    password = ""
    if (req.headers["user"])
      username = req.headers["user"]
    else
      throw swagger.errors.invalid "header"
    if (req.headers["password"])
      password = req.headers["password"]
    else
      throw swagger.errors.invalid "header"
    # Uncrypt the password
    # Authenticate the username Password Combo
    auth.authenticate username , password, (err) ->
      if err
        console.log "There was an error logging in: " + username
        console.log "Error: #{err}"
        res.send "Error in username/password combo"
      else
        console.log "Success! with #{username}"
        # Pass on to database library
        userData.generateNewAPIKey username, (err, keyJSON) ->
          if (err)
            console.log "Error: #{err}"
            res.send "{}"
          else
            res.send JSON.stringify keyJSON


swagger.addPost userLogin
swagger.addGet getUserByUsername
swagger.addGet getAllEvents
swagger.addGet getEventsInRange
swagger.addGet getEventById
swagger.configure "http://superawesome.swagger.imperialEvents.com", "0.1"

httpapp  = app


httpapp.get '/user/*',(req,res) ->
  res.redirect "https://127.0.0.1:#{HTTPS_PORT}#{req.url}"


http.createServer(httpapp).listen HTTP_PORT, ->
  console.log "http running! on port #{HTTP_PORT}"

https.createServer(server_options, app).listen HTTPS_PORT, ->
  console.log "https running! on port #{HTTPS_PORT}"

