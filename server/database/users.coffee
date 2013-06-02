database = require './database'

db = database.db

WE_ARE_NOT_RELATED = -1

createUser = (data, callback) ->
  database.createNode "USERS", data, "USER", callback

# How to treat the permissions??
getUserById = (id, callback) ->
  database.getTableNodeById "USERS", id, (err, user) -> callback err, user

# Returns the list of events a given user has subscribed to
getUserEvents = (id, callback) ->
  query = "START r=Node({rootId}), m=Node({myId})
           MATCH r-[:USERS]->u-->m-[:MEMBER_OF*0..]->g-[:ORGANIZES|:SUBSCRIBED_TO]->event
           RETURN event"
  db.query query, {rootId: database.rootNodeId, myId: id}, (err, events) ->
    if err
      console.log "Error #{err}"
      callback err, null
    else
      callback null, (event.event for event in events)

# Returns the list of friends a given user has
getUserFriends = (id, callback) ->
  query = "START r=Node({rootId}) m=Node({myId})
           MATCH r-[:USERS]->u-->m-[:FRIEND]->f
           RETURN f"
  db.query query, {rootId: database.rootNodeId, myId: id}, (err, friends) ->
    if err
      console.log "Error #{err}"
      callback err, null
    else
      callback null, (friend.f for friend in friends)

# Determines the distance from me to a possible friend.
# Can be used to determine the access permissions
findFriendDistance = (me, friendId, callback) ->
  query = "START r=Node({rootId}), m=Node({myId}), f=Node({friendId})
           MATCH r-[:USERS]->u-->m, r-[:USERS]->u-->f, d=m-[:FRIEND*0..2]->f
           RETURN length(d)"
  db.query query, {rootId: database.rootNodeId, myId: me, friendId: friendId}, (err, lengths) ->
    if err
      console.log "Error: #{err}"
      callback err, null
    else if (lengths.length == 0)
      callback null, WE_ARE_NOT_RELATED
    else
      minDistance = Math.min.apply @, (length for length in lengths)
      callback null, minDistance


# Exporting the functions globally
exports.createUser  = createUser
exports.getUserById = getUserById
exports.getUserFriends = getUserFriends
exports.getUserEvents  = getUserEvents
exports.findFriendDistance = findFriendDistance