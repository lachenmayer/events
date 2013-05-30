express = require 'express'
swagger = require 'swagger-node-express'
swaggerModels = require './models'
eventData = require './database/events'

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
    eventData.getEventById id, (event) ->
      if event
        res.send JSON.stringify(event)
      else
        throw swagger.errors.notFound("event")

getEventInRange =
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
    console.log "Request", req
    throw swagger.errors.invalid("eventRangeRequestHeader")  unless req.params.eventRangeRequestHeader
    events = eventData.getEventsInRange(req.params.eventRangeRequestHeader)
    res.send JSON.stringify(events)


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
    eventData.getAllEvents (events) ->
      if events
        res.send JSON.stringify(events)
      else
        throw swagger.errors.notFound("events")


swagger.addGet getAllEvents
swagger.addGet getEventInRange
swagger.addGet getEventById
swagger.configure("http://petstore.swagger.wordnik.com", "0.1");
  


app.listen PORT, ->
  console.log "running! on port #{PORT}"



