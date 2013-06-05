###
  Library that manages user interactions
  Used to control friend accesses, get user information

  It requires that each user node will contain at least the username and email nodes
###
database = require './database'
async    = require 'async'
#uuid     = require 'node-uuid'
moment   =  require 'moment'

db = database.db

WE_ARE_NOT_RELATED = -1

createUser = (data, callback) ->
  database.createNode "USERS", data, "USER", callback

# How to treat the permissions??
getUserById = (id, callback) ->
  database.getTableNodeById "USERS", id, (err, user) ->
    database.returnValue err, user, ((node) -> database.returnDataWithId node), callback

generateNewAPIKey = (username, callback) ->
  findUserNode username, (err, userNode) ->
    if (err)
      callback err, null
    else
      new_key = uuid.v1()
      timestamp = moment().unix()
      # Traverse to userNode-[:API_KEY]->KEY
      userNode.getRelationshipNodes "API_KEY", (err, nodes) ->
        if (err)
          console.log "Error: #{err}"
          # Make it
          db.createNode({ 'key': new_key, 'timestamp': timestamp }).save (err, api_node) ->
            if (err)
              console.log "Error: #{err}"
            else
              db.createRelationship(userNode, api_node, "API_KEY")
        else
          console.log "Check #{nodes[0]}"
          nodes[0].key = new_key
          nodes[0].timestamp = timestamp
          nodes[0].save (err...) ->
            if err
              console.log "Err: #{err}"






# Returns the list of events a given user has subscribed to
getUserEvents = (id, callback) ->
  query = "START r=Node({rootId}), m=Node({myId})
           MATCH r-[:USERS]->u-->m-[:MEMBER_OF*0..]->g-[:ORGANIZES|:SUBSCRIBED_TO]->event
           RETURN event"
  db.query query, {rootId: database.rootNodeId, myId: id}, (err, events) ->
    database.returnValue err, events, ((data) -> database.returnListWithId (value.event for value in data)), callback

# Returns the list of friends a given user has
getUserRelations = (id, relation, callback) ->
  query = "START r=Node({rootId}), m=Node({myId})
           MATCH r-[:USERS]->u-->m-[:#{relation}]->f
           RETURN f"
  db.query query, {rootId: database.rootNodeId, myId: id}, (err, friends) ->
    database.returnValue err, friends, ((data) -> (value.f.data for value in data)), callback

getUserFriends = (id, callback) ->
  getUserRelations id, "FRIEND", callback

getUserInvited = (id, callback) ->
  getUserRelations id, "INVITED", callback

getUserInvitations = (id, callback) ->
  getUserRelations id, "INVITED_BY", callback

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

# USER1 sends the invitation to USER2
# user1 <node> node of the first user
# user2 <node> node of the second user
invite = (user1, user2, callback) ->
  async.series [
    (callback) -> database.makeRelationship user1, user2, "INVITED", callback
    (callback) -> database.makeRelationship user1, user2, "INVITED_BY", callback
  ], callback

# Accepts the invitation userId2 sent to userId1
# Removes the invitation edge and adds the friends edge
# userId1 <integer> id of the user that accepts the invitation
# userId2 <integer> id of the user that sent the invitation
accept_invitation = (userId1, userId2, callback) ->
  query = "START u1=node({userId1}), u2=node({userId2})
           MATCH u1-[r1:INVITED_BY]->u2, u2-[r2:INVITED]->u1
           CREATE u1-[:FRIEND]->u2<-[:FRIEND]-u1
           DELETE r1, r2"
  db.query query, {userId1: userId1, userId2: userId2}, callback

getUsers = (username1, username2, f, callback) ->
  async.parallel [
    (callback) -> findUserNode username1, callback
    (callback) -> findUserNode username2, callback
  ], (err, users) ->
    database.returnValue err, users, f, callback

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
  f = (users,callback) -> accept_invitation users[0].id, users[1].id, callback
  getUsers username1, username2, f, callback

# Makes the USERNAME1 send a friend invitation to USERNAME2
# username1 <string> name of the first user
# username2 <string> name of the second user
send_invite = (username1, username2, callback) ->
  f = (users, callback) -> invite users[0], users[1], callback
  getUsers username1, username2, f, callback

# Unfriends both people from each other.
# username1 <string> name of the first user
# username2 <string> name of the second user
removeFromFriends = (username1, username2, callback) ->
  f = (users, callback) -> unfriend users[0], users[1], callback
  getUsers username1, username2, f, callback


# Exporting the functions globally
exports.createUser  = createUser
exports.generateNewAPIKey = generateNewAPIKey
exports.getUserById = getUserById
exports.getUserFriends = getUserFriends
exports.getUserEvents  = getUserEvents
exports.getUserInvited     = getUserInvited
exports.getUserInvitations = getUserInvitations
exports.findFriendDistance = findFriendDistance
exports.findUserByUsername = findUser
exports.checkLogIn         = checkLogIn
exports.addToFriends       = addToFriends
exports.send_invite        = send_invite
exports.removeFromFriends  = removeFromFriends
