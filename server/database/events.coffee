database = require('./database.coffee')
db = database.db

getNodeById = (id, handler) ->
  db.getNodeById(id) (err, eventNode) ->
    if (err)
      handler(null)
    else
      handler(eventNode.data)

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