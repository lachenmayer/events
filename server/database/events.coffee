database = require './database'
moment   = require 'moment'
async    = require 'async'
db = database.db

getNodeById = (id, callback) ->
  database.getTableNodeById "EVENT", id, callback

getEventById = (id, callback) ->
  getNodeById id, database.handle callback, (node) ->
    callback null, node.data

getOrganizedEvents = (ownerId, callback) ->
  query = "START owner=node({ownerId})
           MATCH owner-[:ORGANIZES]->e
           RETURN e"
  db.query query, {ownerId: ownerId}, (err, events) ->
    database.returnValue err, events, ((data) -> database.returnListWithId (event.e for event in data)), callback

returnEvents = (query, nodeId, callback) ->
  db.query query, {nodeId: parseInt(nodeId)}, database.handle callback, (events) ->
    console.log "Here"
    callback null, database.returnListWithId (event.e for event in events)

# Returns the list of events a given node is subscribed to
getSubscribedEvents = (nodeId, callback) ->
  query = "START n=node({nodeId})
           MATCH n-[:SUBSCRIBED_TO]->e
           RETURN e"
  returnEvents query, nodeId, callback

# Finds all of the watched events
getEventsOfInterest = (nodeId, callback) ->
  MAX_LENGTH = 3
  query = "START n=node({nodeId})
           MATCH n-[:WATCHING*0..#{MAX_LENGTH}]->()-[:SUBSCRIBED_TO|:ORGANIZES]->e
           RETURN e"
  returnEvents query, nodeId, callback

# Gets the event relation for a given node
getEventRelation = (nodeId, relation, callback) ->
  database.getTableNodeById "EVENT", nodeId, database.handle callback, (node) ->
    async.parallel {
       created:      (callback) -> node.getRelationshipNodes "ORGANIZES", callback
       watching:     (callback) -> node.getRelationshipNodes "WATCHING", callback
       subscribedTo: (callback) -> node.getRelationshipNodes "SUBSCRIBED_TO", callback
    }, database.handle callback, (events) ->
      events.created = database.returnListWithId events.created
      events.watching = database.returnListWithId events.created
      events.subscribedTo = database.returnListWithId events.subscribedTo
      callback null, events

# Creates a new event and returns the id of the event
# Adds the default relationships to denote the event
createEvent = (ownerId, data, callback) ->
  values = database.serializeData data
  query = "START owner=node({ownerId}), root=node({rootId})
           CREATE (e {#{values}}), owner-[:ORGANIZES]->e, root-[:EVENT]->events-[:EVENT]->e
           RETURN e"
  db.query query, {ownerId: ownerId, rootId: database.rootNodeId}, database.handle callback, (event) ->
    callback null, event[0].e.id

findEventNodeById = (eventId, callback) ->
  query = "START e=node({eventId})
           MATCH owner-[:ORGANIZES]->e
           RETURN e"
  db.query query, {eventId: eventId}, database.handle callback, (events) ->
    callback null, events[0].e

updateEvent = (eventId, data, callback) ->
  findEventNodeById eventId, database.handle callback, (eventNode) ->
    for key, value of data
      eventNode.data[key] = value
    eventNode.save database.handle callback, (savedNode) ->
      callback null, savedNode.data

# Removes the event node as well as all of the connections
removeEvent = (eventId, callback) ->
  query = "START event=node({eventId})
           MATCH user-[r:ORGANIZES]->event, event-[rs]-()
           DELETE event, rs, r"
  db.query query, {eventId: eventId}, callback

# Returns all of the events
# The events are sorted according to the date
getAllEvents = (callback) ->
  query = "START root=node({rootId})
           MATCH root-[:EVENT]->events-->e
           WHERE e.date > {from}
           RETURN e
           ORDER BY e.date"
  fromTime = moment().startOf('day').unix()
  db.query query, {rootId: database.rootNodeId, from: fromTime}, database.handle callback, (events) ->
    callback null, database.returnListWithId (e.e for e in events)

getEventsInRange = (query, handler) ->
  query = "START root=Node({rootId})
           MATCH root-[:EVENT]->events-->e
           WHERE e.date > {from}
           AND e.date < {to}
           RETURN e
           ORDER BY e.date ASCN
           SKIP {offset} LIMIT {limit}"
  params =
    rootId: database.rootNodeId,
    from: query.from,
    to: query.to,
    offset: query.offset,
    limit: query.max
  db.query query, params, database.handle handler, (events) ->
      callback null, database.returnListWithId (event.e for event in events)

# Returns the list of users subscribed to the event
getSubscribedUsers = (eventId, callback) ->
  query = "START r=node({rootId}), e=node({eventId})
           MATCH r-[:EVENT]->events-->e<-[:SUBSCRIBED_TO]-u
           RETURN u"
  db.query query, {rootId: database.rootNodeId, eventId: eventId}, database.handle callback, (users) ->
    callback null, database.returnListWithId (n.u for n in users)

makePublicEvent = (event, callback) ->
  database.getTable "EVENT", database.handleErr callback, "Failed getting the table event", (eventNode) ->
    database.makeRelationship eventNode, event, "PUBLIC", callback

exports.createEvent       = createEvent
exports.removeEvent       = removeEvent
exports.findEventNodeById = findEventNodeById
exports.getEventById = getEventById
exports.getAllEvents = getAllEvents
exports.getEventsInRange = getEventsInRange
exports.makePublicEvent  = makePublicEvent
exports.updateEvent      = updateEvent
exports.getOrganizedEvents = getOrganizedEvents
exports.getSubscribedEvents = getSubscribedEvents