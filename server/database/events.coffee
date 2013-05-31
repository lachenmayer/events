database = require('./database.coffee')
db = database.db

getNodeById = (id, handler) ->
  # Returns the node only if it is referenced by the events node
  query = "START e=Node(#{id})
           MATCH events-[:EVENT]->e
           WHERE events.name = \"event\"
           RETURN e"
  db.query query, {}, (err, eventNode) ->
    if err
      console.log "Error: #{err}"
      handler null
    else if (eventNode.length == 0)
      console.log "Error: no results found for id #{id}"
      handler null
    else
      handler eventNode[0].e.data

getAllEvents = (handler) ->
  database.getNode "event", (err, eventNode) ->
    if (err)
      console.log "Error #{err}"
      handler(null)
    else
      eventNode.getRelationshipNodes "EVENT", (err, events) ->
        if (err)
          handler(null)
        else
          handler((event.data for event in events))

getEventsInRange = (query, handler) ->
  query = "START root=#{database.rootNodeId}
           MATCH root-->events-[:EVENT]->e
           WHERE events.name = \"event\"
           AND e.date > #{query.from}
           AND e.date < #{query.to}
           SKIP #{query.offset} LIMIT #{query.max}"
  db.query query, {}, (err, events) ->
    if err
      console.log "Could not find the events in range #{err}"
      handler(null)
    else
      handler((event.e.data for event in events))


exports.getEventById = getNodeById
exports.getAllEvents = getAllEvents
exports.getEventsInRange = getEventsInRange