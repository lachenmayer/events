###
  Library that manages user interactions
  Used to control friend accesses, get user information

  It requires that each user node will contain at least the username and email nodes
###
database = require './database'
async    = require 'async'

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
      console.log "Error in getting user events #{err}"
      callback err, null
    else
      callback null, (event.event for event in events)

# Returns the list of friends a given user has
getUserFriends = (id, callback) ->
  query = "START r=Node({rootId}), m=Node({myId})
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

# Finds and returns a user with specific username
findUserNode = (username, callback) ->
  query = "START r=Node({rootId})
           MATCH r-[:USERS]->u-->user
           WHERE user.username = {username}
           RETURN user"
  db.query query, {rootId: database.rootNodeId, username: username}, (err, users) ->
    if err
      console.log "Could not find the user #{username}: #{err}"
      callback err, null
    else if (users.length == 0)
      console.log "Could not find the user #{username}"
      callback err, null
    else
      callback err, users[0].user

findUser = (username, callback) ->
  findUserNode username, (err, user) ->
    if err
      callback err, user
    else
      # Remove any fields that should not be exposed to the logged in user
      {username, email} = user.data
      callback err, {username: username, email: email}

checkLogIn = (username, password, callback) ->
  findUser username, (err, user) ->
    if err
      callback err, null
    else if (!user || (user.password != password))
      callback "Authorization failed", null
    else
      callback err, user

# Befriends two people
# user1 <node> node of the first user
# user2 <node> node of the second user
befriend = (user1, user2, callback) ->
  async.series [
    (callback) -> database.makeRelationship user1, user2, "FRIEND", callback
    (callback) -> database.makeRelationship user2, user1, "FRIEND", callback
  ], callback

# Links two people as friends
# username1 <string> name of the first user
# username2 <string> name of the second user
addToFriends = (username1, username2, callback) ->
  async.parallel [
    (callback) -> findUserNode username1, callback
    (callback) -> findUserNode username2, callback
  ], (err, users) ->
    [user1, user2] = users
    if err
      callback err, null
    else
      befriend user1, user2, callback

# Unfriends both people from each other
# userId1 <integer> id of the node for the first user
# userId2 <integer> id of the node for the second user
unfriend = (userId1, userId2, callback) ->
  query = "START a=node({id1}), b=node({id2})
           MATCH a-[r:FRIEND]-b
           DELETE r"
  db.query query, {id1: userId1, id2: userId2}, callback

# Unfriends both people from each other.
# username1 <string> name of the first user
# username2 <string> name of the second user
removeFromFriends = (username1, username2, callback) ->
  async.parallel [
    (callback) -> findUser username1, callback
    (callback) -> findUser username2, callback
  ], (err, users) ->
    [user1, user2] = users
    if err
      callback err, null
    else
      unfriend user1, user2, callback


# Exporting the functions globally
exports.createUser  = createUser
exports.getUserById = getUserById
exports.getUserFriends = getUserFriends
exports.getUserEvents  = getUserEvents
exports.findFriendDistance = findFriendDistance
exports.findUserByUsername = findUser
exports.checkLogIn         = checkLogIn
exports.addToFriends       = addToFriends
exports.removeFromFriends  = removeFromFriends