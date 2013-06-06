express       = require 'express'
swagger       = require 'swagger-node-express'
swaggerModels = require './models'
eventData     = require './database/events'
userData      = require './database/users'
database      = require './database/database'
tagData       = require './database/tags'
auth          = require './authenticate'
groups        = require './database/groups'
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

postGroupEvent =
  spec:
    description: "Creates a new group event"
    path: "/new/event"
    notes: "Creates a new event by the given group"
    method: "POST"
    params: []
    responseClass: "event"
    errorResponses: [swagger.errors.invalid("event")]
    nickname: "postGroupEvent"
  action: (req, res) ->
    throw swagger.errors.invalid("event") unless (req.query.from and req.query.to)
    # TODO: use the passport and key verification
    # TODO: parse data and the user
    data = {}
    user = 'newName'
    eventData.createEvent user, data, returnJson(res, "event")

postChangeEvent =
  spec:
    description: "Changes an existing event"
    path: "/event/{id}/change"
    notes: "Modifies the currently existing event in the database"
    method: "POST"
    params: []
    responseClass: "event"
    errorResponses: [swagger.errors.invalid("event")]
    nickname: "postChangeEvent"
  action: (req, res) ->
    throw swagger.errors.invalid("event") unless (req.query.id and req.query.data)
    # TODO: Validate the input POST query
    id = parseInt req.query.id
    data = {}
    eventData.updateEvent id, data, returnJson(res, "event")

postDeleteEvent =
  spec:
    description: "Deletes an event"
    path: "/event/{id}"
    notes: "Removes the event from the list of existing events"
    method: "DELETE"
    params: []
    responseClass: "event"
    errorResponses: []
    nickname: "postDeleteEvent"
  action: (req, res) ->
    throw swagger.errors.invalid("event") unless (req.query.id)
    id = parseInt req.query.id
    eventData.removeEvent id, returnJson(res, "event")

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
    if (req.headers["username"])
      username = req.headers["username"]
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

getAllTags =
  spec:
    description: "Get all of the tags"
    path: "/tags/ALL"
    notes: "Returns all of the tags saved in the database"
    method: "GET"
    params: []
    responseClass: "List[tag]"
    errorResponses: [swagger.errors.notFound("tag")]
    nickname: "getAllTags"
  action: (req, res) ->
    tagData.getAllTags returnJson(res, "tags")


swagger.addPost userLogin
swagger.addGet getUserByUsername
swagger.addGet getAllTags
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

