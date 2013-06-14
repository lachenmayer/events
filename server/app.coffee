express       = require 'express'
swagger       = require 'swagger-node-express'
swaggerModels = require './models'
eventData     = require './database/events'
userData      = require './database/users'
calendarData  = require './calendar'
database      = require './database/database'
tagData       = require './database/tags'
auth          = require './authenticate'
groups        = require './database/groups'
fs            = require 'fs'
http          = require 'http'
https         = require 'https'

server_options =
  key: fs.readFileSync "#{__dirname}/cert/server.key"
  cert: fs.readFileSync "#{__dirname}/cert/server.crt"
  requestCert: true
  passphrase: 'alexiscool'

app = express()

HTTP_PORT  = 5278
HTTPS_PORT = 5279
LOGIN_URL  = '/user/login'

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
    console.log err
    res.status(404).send "404: invalid data. Cannot return #{field}"
  else
    value = {} unless value?
    res.send JSON.stringify value

# TODO: get the logged in user id
# If cannot log on should throw an error
getLoggedInUser = (callback) -> (req, res) ->
  #req.cookie.userId = 12312
  #req.cookie.key = blah
  if not req.cookie.userId
    userId = 23064 # Generate from key, work it out
  else userId = req.cookie.userId
  if not req.cookie.key
    key = "blahblahblah"
  else key = req.cookie.key
  userData.getUserById userId, (err, user) ->
    if err
      callback req, res, null
    else
      callback req, res, { id: userId, username: user.username }

# Requires the user to be logged in
requireLoggedInUser = (callback) -> (req, res) ->
  getLoggedInUser((req, res, user) ->
    if user
      callback req, res, user
    else
      res.status(401).send "401: invalid data. Cannot return"
  )(req, res)

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

getEventsFromTag =
  spec:
    decription: "Find events by tag"
    path: "/events.json/getEventsFromTag/{tag}"
    notes: "Returns a list of events tagged with the given tag"
    summary: "Find events by tag"
    method: "GET"
    params: []
    responseClass: "List[event]"
    errorResponses: [swagger.errors.invalid("tag"), swagger.errors.notFound("event")]
    nickname: "getEventsFromTag"
  action: (req, res) ->
    console.log "GetEventsFromTag #{req.params.tag}"
    eventData.findEventNodeFromTag req.params.tag, returnJson(res, "events")

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
    path: "/event"
    notes: "Creates a new event by the given group"
    method: "POST"
    params: []
    responseClass: "event"
    errorResponses: [swagger.errors.invalid("event")]
    nickname: "postGroupEvent"
  action: requireLoggedInUser (req, res, user) ->
    throw swagger.errors.invalid("event") unless (\
      req.query.name \
      and req.query.location \
      and req.query.description)
    if not req.query.image     
      req.query.image = ""
    data =
      name: req.query.name
      location: req.query.location
      image: req.query.image
      url: req.query.url
      description: req.query.description
      host: user.username

    userData.findUserByUsername user.username, (err, user) ->
      if err
        throw swagger.invalid("user")
      else
        eventData.createEvent user.id, data, returnJson(res, "event")

# Checks for update instructions if the fields given by the user
# are a subset of the fields that belong to the model
usesKeys = (data, keys) ->
  for key of data
    if !(key in keys)
      return false
  return true

postChangeEvent =
  spec:
    description: "Changes an existing event"
    path: "/event/{id}/edit"
    notes: "Modifies the currently existing event in the database"
    method: "POST"
    params: []
    responseClass: "event"
    errorResponses: [swagger.errors.invalid("event")]
    nickname: "postChangeEvent"
  action: requireLoggedInUser (req, res) ->
    data = req.body
    throw swagger.errors.invalid("event") unless (req.params.id and req.body \
      and usesKeys data, (key for key of swaggerModels.models.event.properties))
    id = parseInt req.params.id

    # TODO: authorize the user
    eventData.updateEvent id, data, returnJson(res, "event")

postDeleteEvent =
  spec:
    description: "Deletes an event"
    path: "/event/{id}"
    notes: "Removes the event from the list of existing events"
    method: "DELETE"
    params: []
    responseClass: "event"
    errorResponses: [swagger.errors.invalid("event")]
    nickname: "postDeleteEvent"
  action: requireLoggedInUser (req, res) ->
    throw swagger.errors.invalid("event") unless req.params.id
    id = parseInt req.params.id

    # TODO: authorize the user
    eventData.removeEvent id, (err) ->
      returnJson(res, "event")(null, {success: !err})

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
    if (req.body["username"])
      username = req.body["username"]
    else
      throw swagger.errors.invalid "header"
    if (req.body["password"])
      password = req.body["password"]
    else
      throw swagger.errors.invalid "header"
    # Uncrypt the password
    # Authenticate the username Password Combo
    auth.authenticate username, password, (err) ->
      if err
        console.log "There was an error logging in: " + username
        console.log "Error: #{err}"
        res.send "{\"error\": \"#{err}\"}"
      else
        console.log "Success! with #{username}"
        # Pass on to database library
        userData.generateNewAPIKey username, (err, keyJSON) ->
          if (err)
            console.log "Error: #{err}"
            res.send "{}"
          else
            res.send JSON.stringify keyJSON

createICalURL =
  spec:
    description: "Creates a new ICal URL for the logged in user"
    path: "/calendar/new"
    notes: "If the URL is already defined deletes the old one and creates a new one"
    method: "GET"
    params: []
    responseClass: "integer"
    errorResponses: []
    nickname: "createICalURL"
  action: requireLoggedInUser (req, res, user) ->
    calendarData.createICalURL user.id, returnJson(res, "icalURL")

getICalURL =
  spec:
    description: "Gets the ICal URL for the currently logged in user"
    path: "/calendar/URL"
    notes: ""
    method: "GET"
    params: []
    responseClass: "string"
    errorResponses: [swagger.errors.invalid("icalURL")]
    nickname: "getICalURL"
  action: requireLoggedInUser (req, res, user) ->
    calendarData.getICalURL user.id, returnJson(res, "icalURL")

getICal =
  spec:
    description: "Returns the ical using the ical token"
    path: "/calendar/{id}"
    notes: ""
    method: "GET"
    params: []
    responseClass: "string"
    errorResponses: [swagger.errors.invalid("id"), swagger.errors.notFound("calendar")]
    nickname: "getICal"
  action: (req, res) ->
    throw swagger.errors.invalid("id") unless req.params.id
    calendarData.getICal req.params.id, returnJson(res, "userId")

deleteICalURL =
  spec:
    description: "Makes the current user remove his ical url"
    path: "/calendar"
    notes: ""
    method: "DELETE"
    params: []
    responseClass: "string"
    errorResponses: []
    nickname: "deleteICalURL"
  action: requireLoggedInUser (req, res, user) ->
    calendarData.removeICalURL user.id, returnJson(res, "icalURL")

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

getUserTags =
  spec:
    description: "Returns all of the tags that a user will use"
    path: "/user/tags"
    notes: "Returns the list of all tags. Adds the subsribed field to state which tags were subscribed by the user"
    method: "GET"
    params: []
    responseClass: "List[tag]"
    errorResponses: [swagger.errors.notFound("tag")]
    nickname: "getUserTags"
  action: requireLoggedInUser (req, res, user) ->
    tagData.getUserTags user.id, returnJson(res, "tag")

createNewGroup =
  spec:
    description: "Ceates a new group"
    path: "/groups/new"
    notes: ""
    method: "POST"
    params: []
    responseClass: "integer"
    errorResponses: [swagger.errors.invalid("group")]
    nickname: "createNewGroup"
  action: requireLoggedInUser (req, res, user) ->
    data =
      value: "value"
    groups.createGroup user.id, data, returnJson(res, "group")

deleteGroup =
  spec:
    description: "Deletes an existing group"
    path: "/groups/{id}"
    notes: ""
    method: "DELETE"
    params: []
    responseClass: "string"
    errorResponses: [swagger.errors.invalid("id")]
    nickname: "deleteGroup"
  action: requireLoggedInUser (req, res) ->
    throw swagger.errors.invalid("id") unless req.params.id
    id = parseInt req.params.id

    # TODO: authorize the user
    groups.deleteGroup id, returnJson(res, "id")

joinGroup =
  spec:
    description: "Subscribes to a group"
    path: "/groups/{id}/join"
    notes: ""
    method: "GET"
    params: []
    responseClass: "string"
    errorResponses: []
    nickname: "joinGroup"
  action: requireLoggedInUser (req, res, user) ->
    throw swagger.errors.invalid("id") unless req.params.id
    id = parseInt req.params.id

    # TODO: authorize the user
    groups.joinGroup user.id, id, returnJson(res, "id")

leaveGroup =
  spec:
    description: "Leaves a group"
    path: "/groups/{id}/leave"
    notes: ""
    method: "GET"
    params: []
    responseClass: "string"
    errorResponses: []
    nickname: "leaveGroup"
  action: requireLoggedInUser (req, res, user) ->
    throw swagger.errors.invalid("id") unless req.params.id
    id = parseInt req.params.id
    # TODO: authorize the user
    groups.leaveGroup user.id, id, returnJson(res, "id")

removeFromGroup =
  spec:
    description: "removes a member of the group"
    path: "/groups/{id}/remove"
    notes: ""
    method: "POST"
    params: []
    responseClass: "string"
    errorResponses: []
    nickname: "removeFromGroup"
  action: requireLoggedInUser (req, res, user) ->
    throw swagger.errors.invalid("id") unless (req.params.id and req.body.userId)
    groupId = parseInt req.params.id

    removeUserId = parseInt req.body.userId

    groups.removeFromGroup user.id, removeUserId, groupId, returnJson(res, "id")

getSubscribedEvents =
  spec:
    description: "Returns the list of subscribed to events"
    path: "/user/subscribed"
    notes: ""
    method: "GET"
    params: []
    responseClass: "string"
    errorResponses: []
    nickname: "getSubscribedEvents"
  action: requireLoggedInUser (req, res, user) ->
    userData.getUserEvents user.id, returnJson(res, "events")

subscribeToTag =
  spec:
    description: "Subscribes to a tag list"
    path: "/tags/{id}/subscribe"
    notes: ""
    method: "GET"
    params: []
    responseClass: "string"
    errorResponses: []
    nickname: "subscribeToTag"
  action: requireLoggedInUser (req, res, user) ->
    throw swagger.errors.invalid("id") unless req.params.id
    id = parseInt req.params.id
    console.log "Subscribing"

    userData.subscribeTo user.id, id, returnJson(res, "success")

unsubscribeTag =
  spec:
    description: "Unsubscribes from a tag list"
    path: "/tags/{id}/unsubscribe"
    notes: ""
    method: "GET"
    params: []
    responseClass: "string"
    errorResponses: []
    nickname: "unsubscribeTag"
  action: requireLoggedInUser (req, res, user) ->
    throw swagger.errors.invalid("id") unless req.params.id
    id = parseInt req.params.id

    userData.unsubscribeFrom user.id, id, returnJson(res, "success")

subscribeToEvent =
  spec:
    description: "Subscribes to an event"
    path: "/event.json/{id}/subscribe"
    notes: ""
    method: "GET"
    params: []
    responseClass: "string"
    errorResponses: [swagger.errors.invalid("id")]
    nickname: "subscribeToEvent"
  action: requireLoggedInUser (req, res, user) ->
    console.log "Subscribing"
    throw swagger.errors.invalid("id") unless req.params.id
    id = parseInt req.params.id

    userData.subscribeTo user.id, id, returnJson(res, "success")

unsubscribeFromEvent =
  spec:
    description: "Unsubscribes from an event"
    path: "/event.json/{id}/unsubscribe"
    notes: ""
    method: "GET"
    params: []
    responseClass: "string"
    errorResponses: [swagger.errors.invalid("id")]
    nickname: "unsubscribeFromEvent"
  action: requireLoggedInUser (req, res, user) ->
    throw swagger.errors.invalid("id") unless req.params.id
    id = parseInt req.params.id

    userData.unsubscribeFrom user.id, id, returnJson(res, "success")

swagger.addPost userLogin
swagger.addGet getUserByUsername
swagger.addGet getAllTags
swagger.addGet getAllEvents
swagger.addGet getEventsInRange
swagger.addGet getEventsFromTag
swagger.addGet getEventById
swagger.addPost postChangeEvent
swagger.addPut postGroupEvent
swagger.addDelete postDeleteEvent
swagger.addGet getICalURL
swagger.addGet createICalURL
swagger.addDelete deleteICalURL
swagger.addGet getICal
swagger.addPost removeFromGroup
swagger.addGet leaveGroup
swagger.addGet joinGroup
swagger.addDelete deleteGroup
swagger.addPost createNewGroup
swagger.addGet getSubscribedEvents
swagger.addGet subscribeToEvent
swagger.addGet unsubscribeFromEvent
swagger.addGet subscribeToTag
swagger.addGet unsubscribeTag
swagger.addGet getUserTags
swagger.configure "http://superawesome.swagger.imperialEvents.com", "0.1"

httpapp  = app


httpapp.get '/user/*',(req,res) ->
  res.redirect "https://127.0.0.1:#{HTTPS_PORT}#{req.url}"


http.createServer(httpapp).listen HTTP_PORT, ->
  console.log "http running! on port #{HTTP_PORT}"

https.createServer(server_options, app).listen HTTPS_PORT, ->
  console.log "https running! on port #{HTTPS_PORT}"

