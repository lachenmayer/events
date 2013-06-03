database = require('./database.coffee')
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
           RETURN e
           ORDER BY e.date"
  db.query query, {rootId: database.rootNodeId}, (err, events) ->
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
