database = require('./database.coffee')
moment   = require 'moment'
db = database.db

getNodeById = (id, callback) ->
  database.getTableNodeById "EVENT", id, callback

getEventById = (id, callback) ->
  getNodeById id, database.handle callback, (node) ->
    callback null, node.data

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
    database.makeRelationship eventNode, event, "EVENT", callback

exports.getEventById = getEventById
exports.getAllEvents = getAllEvents
exports.getEventsInRange = getEventsInRange
exports.makePublicEvent  = makePublicEvent
