express = require 'express'
swagger = require 'swagger-node-express'
swaggerModels = require './models'
eventData = require './database/events'
everyauth = require 'everyauth'
userData  = require './database/users'

app = express()


PORT = 5278

app.use express.compress()
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser()

app.use express.session secret: 'alex is cool'
app.use express.logger 'dev'

swagger.setAppHandler app

# swagger.addValidator validate = (req, path, httpMethod) ->  
#   #  example, only allow POST for api_key="special-key"
#   if "POST" is httpMethod or "DELETE" is httpMethod or "PUT" is httpMethod
#     apiKey = req.headers["api_key"]
#     apiKey = url.parse(req.url, true).query["api_key"]  unless apiKey
#     return true  if "special-key" is apiKey
#     return false
#   true

swagger.addModels swaggerModels

returnJson = (res) -> (value) ->
  if value
    res.send JSON.stringify value
  else
    res.send JSON.stringify {}

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
    eventData.getEventById id, returnJson(res)

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
    errorResponses: [swagger.errors.invalid("eventRangeRequestHeader")]
    nickname: "getEventInRange"
  action: (req, res) ->
    console.log "Request Query", req.query
    throw swagger.errors.invalid("eventRangeRequestHeader")  unless (\
      req.query.from \
      and req.query.to\
      and req.query.max\
      and req.query.offset)
    eventData.getEventsInRange req.query, returnJson(res)

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
    eventData.getAllEvents (err, events) ->
      if err
        console.log "Error #{err}"
        throw swagger.errors.notFound("events")
      else if events
        res.send JSON.stringify(events)
      else
        throw swagger.errors.notFound("events")


swagger.addGet getUserByUsername
swagger.addGet getAllEvents
swagger.addGet getEventsInRange
swagger.addGet getEventById
swagger.configure("http://petstore.swagger.wordnik.com", "0.1");

everyauth.helpExpress app


app.listen PORT, ->
  console.log "running! on port #{PORT}"



