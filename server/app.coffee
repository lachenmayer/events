express = require 'express'
swagger = require 'swagger-node-express'
swaggerModels = require './models'

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
    nickname: "getEventById"

  action: (req, res) ->
    throw swagger.errors.invalid("eventId")  unless req.params.eventId
    id = parseInt(req.params.eventId)
    event = eventData.getEventById(id)
    if event
      res.send JSON.stringify(event)
    else
      throw swagger.errors.notFound("event")

swagger.addGet getEventById
swagger.configure("http://petstore.swagger.wordnik.com", "0.1");



app.listen PORT, ->
  console.log "running! on port #{PORT}"



