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

exports.getEventById = getNodeById
exports.getAllEvents = getAllEvents