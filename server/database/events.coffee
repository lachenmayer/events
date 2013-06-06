database = require './database'
moment   = require 'moment'
async    = require 'async'
db = database.db

getNodeById = (id, callback) ->
  database.getTableNodeById "EVENT", id, callback

getEventById = (id, callback) ->
  getNodeById id, database.handle callback, (node) ->
    callback null, node.data

updateEvent = (eventId, data, callback) ->
  findEventNodeById eventId, database.handle callback, (eventNode) ->
    for key, value of data
      eventNode[key] = value
    eventNode.save callback

getOrganizedEvents = (ownerId, callback) ->
  query = "START owner=node({ownerId})
           MATCH owner-[:ORGANIZES]->e
           RETURN e"
  db.query query, {ownerId: ownerId}, callback

createEvent = (ownerId, data, callback) ->
  query = "START owner=node({ownerId}), root=node({rootId})
           CREATE (e {#{data}}), owner-[:ORGANIZES]->e, root-[:EVENT]->events-[:EVENT]->e"
  db.query query, {ownerId: ownerId, rootId: database.rootNodeId}, callback

# Removes the event node as well as all of the connections
removeEvent = (eventId, callback) ->
  findEventNodeById eventId, database.handle callback, (eventNode) ->
    f = (((callback) -> relationship.delete(callback)) for relationship in eventNode.relationships)
    async.parallel f, database.handle callback, -> eventNode.delete callback

findEventNodeById = (eventId, callback) ->
  query = "START e=node({eventId})
           MATCH owner-[:ORGANIZES]->e
           RETURN e"
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
           MATCH r-[:EVENT]->events-->e<-[:SUBSCRIBED_TO]-u<--users<-[:USERS]-r
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