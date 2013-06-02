database = require('./database.coffee')
db = database.db

getNodeById = (id, handler) ->
  database.getTableNodeById "EVENT", id, (err, node) -> handler node

getAllEvents = (handler) ->
  database.getTable "EVENT", (err, eventNode) ->
    if (err)
      console.log "Error #{err}"
      handler(null)
    else
      eventNode.getRelationshipNodes "EVENT", (err, events) ->
        if err
          handler(null)
        else
          handler((event.data for event in events))

getEventsInRange = (query, handler) ->
  query = "START root=Node(rootId)
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
      handler((event.e.data for event in events))


makePublicEvent = (event, callback) ->
  database.getTable "EVENT", (err, eventNode) ->
    if err
      console.log "Failed getting the table event: #{err}"
    else
      database.makeRelationship eventNode, event, "EVENT", callback

exports.getEventById = getNodeById
exports.getAllEvents = getAllEvents
exports.getEventsInRange = getEventsInRange
exports.makePublicEvent  = makePublicEvent
