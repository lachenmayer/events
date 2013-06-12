###
  Library that manages user interactions
  Used to control friend accesses, get user information

  It requires that each user node will contain at least the username and email nodes
###
database = require './database'
async    = require 'async'
uuid     = require 'node-uuid'
moment   =  require 'moment'

db = database.db

WE_ARE_NOT_RELATED = -1

# Defines a user node for a new username
userNode = (username) ->
  return {
    username: username
    joinDate: moment().unix()
  }

# Creates a new user and creates the default data for it
newUser = (username, callback) ->
  createUser (userNode username), callback

createUserSimple = (username, callback) ->
  createUser {"username": username, "joinTimestamp": moment().unix() }, database.handle callback, (userNode) ->
    createAPIKeyNode userNode, callback

createAPIKeyNode = (userNode, callback) ->
  db.createNode({ 'key': '', 'timestamp': ''}).save database.handle callback, (apiNode) ->
    database.makeRelationship userNode, apiNode, "API_KEY", database.handle callback, ->
      callback null, userNode

# Sets up the new user
createUser = (data, callback) ->
  database.createNode "USERS", data, "USER", database.handle callback, (userNode) ->
    createAPIKeyNode userNode, callback

# Removes the API key for the given user from the database
removeAPIKey = (username, callback) ->
  query = "START r=node({rootId})
             MATCH r-[:USERS]->users-->u-[rAPI:API_KEY]->ap
             WHERE u.username = {username}
             DELETE ap, rAPI"
  db.query query, {rootId: database.rootNodeId, username: username}, callback

# Removes a user with a given username from the database
removeUser = (username, callback) ->
  async.parallel [
    (callback) -> removeAPIKey username, callback
  ], database.handle callback, ->
    # Might need to remove the friends edges as well
    query = "START r=node({rootId})
                 MATCH r-[:USERS]->users-[field]->u
                 WHERE u.username = {username}
                 DELETE field, u"
    db.query query, {rootId: database.rootNodeId, username: username}, database.handle callback, ->
      console.log "User removed #{username}"
      callback null, null


# How to treat the permissions??
getUserById = (id, callback) ->
  database.getTableNodeById "USERS", id, (err, user) ->
    database.returnValue err, user, ((node) -> database.returnDataWithId node), callback

generateNewAPIKey = (username, callback) ->
  findOrCreateUserNode username, database.handle callback, (userNode) ->
    new_key = uuid.v1()
    timestamp = moment().unix()
    # Traverse to userNode-[:API_KEY]->KEY
    userNode.getRelationshipNodes "API_KEY", database.handle callback, (nodes) ->
      if not nodes or not nodes[0]
        createAPIKeyNode userNode, ()->
          callback "User #{username} corrupted, no API_KEY node. Recovery Attempted", null
      else
        nodes[0].data.key = new_key
        nodes[0].data.timestamp = timestamp
        nodes[0].save database.handle callback, (new_node) ->
          callback null, {"key": new_key, "id": new_node.id}

# Verifies the key and returns whether the USERNAME, KEYAPI combination is valid
verifyKey = (username, keyAPI, callback) ->
  findUserNode username, database.handle callback, (userNode) ->
    userNode.getRelationshipNodes 'API_KEY', database.handle callback, (nodes) ->
      validated = nodes[0].data.key == keyAPI && nodes[0].data.timestamp > moment().unix()
      callback null, validated

# Subscribes to an event
subscribeTo = (userId, nodeId, callback) ->
  query = "START r=node({rootId}), u=node({userId}), n=node({eventId})
           MATCH r-[:EVENT]->ev-->n
           CREATE u-[:SUBSCRIBED_TO]->n"
  console.log "query does not work"

  db.query query, {rootId: database.rootNodeId, userId: userId, eventId: nodeId}, database.handle callback, ->
    callback null, {success: true}

# Unsubscribes from an event
unsubscribeFrom = (userId, nodeId, callback) ->
  query = "START r=node({rootId}), u=node({userId}), n=node({eventId})
           MATCH r-[:EVENT]->()-->n, u-[s:SUBSCRIBED_TO]->n
           DELETE s"
  db.query query, {rootId: database.rootNodeId, userId: userId, eventId: nodeId}, database.handle callback, ->
    callback null, {success: true}

# Returns the list of events a given user has subscribed to
getUserEvents = (id, callback) ->
  query = "START r=Node({rootId}), m=Node({myId})
           MATCH r-[:USERS]->u-->m-[:MEMBER_OF*0..]->g-[:ORGANIZES|SUBSCRIBED_TO]->event
           RETURN event"
  db.query query, {rootId: database.rootNodeId, myId: id}, (err, events) ->
    database.returnValue err, events, ((data) -> database.returnListWithId (value.event for value in data)), callback

# Returns the list of friends a given user has
getUserRelations = (username, relation, callback) ->
  query = "START r=Node({rootId})
           MATCH r-[:USERS]->u-->m-[:#{relation}]->f
           WHERE m.username = {username}
           RETURN f"
  db.query query, {rootId: database.rootNodeId, username: username}, (err, friends) ->
    database.returnValue err, friends, ((data) -> (value.f.data for value in data)), callback

getUserFollowing = (username, callback) ->
  getUserRelations username, "FOLLOWING", callback

getUserFriends = (username, callback) ->
  getUserRelations username, "FRIEND", callback

getUserInvited = (username, callback) ->
  getUserRelations username, "INVITED", callback

getUserInvitations = (username, callback) ->
  getUserRelations username, "INVITED_BY", callback

# Determines the distance from me to a possible friend.
# Can be used to determine the access permissions
findFriendDistance = (me, friendId, callback) ->
  query = "START r=Node({rootId}), m=Node({myId}), f=Node({friendId})
           MATCH r-[:USERS]->u-->m, r-[:USERS]->u-->f, d=m-[:FRIEND*0..2]->f
           RETURN length(d)"
  db.query query, {rootId: database.rootNodeId, myId: me, friendId: friendId}, database.handle callback, (lengths) ->
    if (lengths.length == 0)
      callback null, WE_ARE_NOT_RELATED
    else
      minDistance = Math.min.apply @, (length for length in lengths)
      callback null, minDistance

# Finds and returns a user with specific username
findUserNode = (username, callback) ->
  findMatchingUsers username, database.handle callback, (users) ->
    if (users.length == 0)
      errMsg = "Could not find the user #{username}"
      console.log errMsg
      callback errMsg, null
    else
      callback null, users[0].user

# Finds and returns the list of matching users
findMatchingUsers = (username, callback) ->
  query = "START r=Node({rootId})
             MATCH r-[:USERS]->u-->user
             WHERE user.username = {username}
             RETURN user"
  db.query query, {rootId: database.rootNodeId, username: username},
    database.handleErr callback, "Could not find the user #{username}", (users) ->
      callback null, users

# Tries to find a user. If one does not exist sets up a new node
findOrCreateUserNode = (username, callback) ->
  findMatchingUsers username, database.handle callback, (users) ->
    if (users.length == 0)
      newUser username, callback
    else
    return users[0].user

# Finds a user
# Assumes that the user exists
# If the user might not exist use findMatchingUsers instead
# username <string> username
findUser = (username, callback) ->
  findUserNode username, database.handle callback, (user) ->
    # Remove any fields that should not be exposed to the logged in user
    {username, email} = user.data
    callback null, {id: user.id, username: username, email: email}

checkLogIn = (username, password, callback) ->
  findUser username, database.handle callback, (user) ->
    if (!user || (user.password != password))
      callback "Authorization failed", null
    else
      callback null, user

# USER1 sends the invitation to USER2
# user1 <node> node of the first user
# user2 <node> node of the second user
invite = (user1, user2, callback) ->
  async.series [
    (callback) -> database.makeRelationship user1, user2, "INVITED", callback
    (callback) -> database.makeRelationship user2, user1, "INVITED_BY", callback
  ], callback

# Accepts the invitation userId2 sent to userId1
# Removes the invitation edge and adds the friends edge
# userId1 <integer> id of the user that accepts the invitation
# userId2 <integer> id of the user that sent the invitation
accept_invitation = (userId1, userId2, callback) ->
  query = "START u1=node({userId1}), u2=node({userId2})
           MATCH u1-[r1:INVITED_BY]->u2, u2-[r2:INVITED]->u1
           CREATE u1-[:FRIEND]->u2-[:FRIEND]->u1
           DELETE r1, r2"
  db.query query, {userId1: userId1, userId2: userId2}, callback

followAPerson = (user1, user2, callback) ->
  async.series [
    (callback) -> database.makeRelationship user1, user2, "FOLLOWING", callback
  ], callback

getUsers = (username1, username2, callback) ->
  async.parallel [
    (callback) -> findUserNode username1, callback
    (callback) -> findUserNode username2, callback
  ], callback

# Unfriends both people from each other
# userId1 <integer> id of the node for the first user
# userId2 <integer> id of the node for the second user
unfriend = (userId1, userId2, callback) ->
  query = "START a=node({id1}), b=node({id2})
           MATCH a-[r:FRIEND]-b
           DELETE r"
  db.query query, {id1: userId1, id2: userId2}, callback

# Links two people as friends
# username1 <string> name of the first user
# username2 <string> name of the second user
addToFriends = (username1, username2, callback) ->
  getUsers username1, username2, database.handle callback, (users) ->
    accept_invitation users[0].id, users[1].id, callback

# Makes the USERNAME1 send a friend invitation to USERNAME2
# username1 <string> name of the first user
# username2 <string> name of the second user
send_invite = (username1, username2, callback) ->
  getUsers username1, username2, database.handle callback, (users) ->
    invite users[0], users[1], callback

# Unfriends both people from each other.
# username1 <string> name of the first user
# username2 <string> name of the second user
removeFromFriends = (username1, username2, callback) ->
  getUsers username1, username2, database.handle callback, (users) ->
    unfriend users[0].id, users[1].id, callback

unfollowAPerson = (username1, username2, callback) ->
  getUsers username1, username2, database.handle callback, (users) ->
    async.series [
      (callback) -> database.removeRelationship users[0], users[1], "FOLLOWING", callback
    ], callback

stalkAPerson = (username1, username2, callback) ->
  getUsers username1, username2, database.handle callback, (users) ->
    followAPerson users[0], users[1], callback

# Exporting the functions globally
exports.newUser     = newUser
exports.generateNewAPIKey = generateNewAPIKey
exports.getUserById = getUserById
exports.getUserFriends = getUserFriends
exports.getUserEvents  = getUserEvents
exports.removeUser         = removeUser
exports.getUserInvited     = getUserInvited
exports.getUserInvitations = getUserInvitations
exports.getUserFollowing   = getUserFollowing
exports.findFriendDistance = findFriendDistance
exports.findUserByUsername = findUser
exports.checkLogIn         = checkLogIn
exports.addToFriends       = addToFriends
exports.send_invite        = send_invite
exports.removeFromFriends  = removeFromFriends
exports.followAPerson      = stalkAPerson
exports.unfollowAPerson    = unfollowAPerson
exports.subscribeTo        = subscribeTo
exports.unsubscribeFrom    = unsubscribeFrom
