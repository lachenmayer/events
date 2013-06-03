database = require('./database.coffee')
moment   = require 'moment'
db = database.db

getNodeById = (id, callback) ->
  database.getTableNodeById "EVENT", id, callback

getEventById = (id, callback) ->
  getNodeById id, (err, node) ->
    database.returnValue err, node, ((node) -> node.data), (err, node) -> callback node

# Returns all of the events
# The events are sorted according to the date
getAllEvents = (handler) ->
  query = "START root=node({rootId})
           MATCH root-[:EVENT]->events-->e
           WHERE e.date > {from}
           RETURN e
           ORDER BY e.date"
  fromTime = moment().startOf('day').unix()
  db.query query, {rootId: database.rootNodeId, from: fromTime}, (err, events) ->
    f = (nodes) -> database.returnListWithId (e.e for e in nodes)
    database.returnValue err, events, f, handler

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
  db.query query, params, (err, events) ->
    if err
      handler(null)
    else
      handler(database.returnListWithId (event.e for event in events))

# Returns the list of users subscribed to the event
getSubscribedUsers = (eventId, callback) ->
  query = "START r=node({rootId}), e=node({eventId})
           MATCH r-[:EVENT]->events-->e<-[:SUBSCRIBED_TO]-u<--users<-[:USERS]-r
           RETURN u"
  db.query query, {rootId: database.rootNodeId, eventId: eventId}, (err, users) ->
    database.returnValue err, users, ((nodes) -> database.returnListWithId (n.u for n in nodes)), callback

makePublicEvent = (event, callback) ->
  database.getTable "EVENT", (err, eventNode) ->
    if err
      console.log "Failed getting the table event: #{err}"
    else
      database.makeRelationship eventNode, event, "EVENT", callback

exports.getEventById = getEventById
exports.getAllEvents = getAllEvents
exports.getEventsInRange = getEventsInRange
exports.makePublicEvent  = makePublicEvent
