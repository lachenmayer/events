###
  A library that allows group or societies management
###
database = require './database.coffee'
async    = require 'async'

db = database.db

# Creates the group with DATA
# The owner of the group is assigned to USERID
createGroup = (userId, data, callback) ->
  database.createNode "GROUP", data, "GROUP", database.handle callback, (groupNode) ->
    query = "START r=node({rootId}), u=({userId}), g=({groupId})
             MATCH r-[:USERS]->users-->u
             CREATE g-[:OWNER]->u, u-[:MEMBER_OF]->g
             RETURN g"
    params = {rootId: database.rootNodeId, userId: userId, groupId: groupNode.id}
    db.query query, params, database.handle callback, (users) ->
      callback null, {id: users[0].g.id}

# Makes a user join the group
joinGroup = (userId, groupId, callback) ->
  query = "START u=node({userId}), g=node({groupId})
           CREATE u-[:MEMBER_OF]->g, g-[:IS_MEMBER]->u"
  db.query query, {userId: userId, groupId: groupId}, database.handle callback, ->
    callback null, {success: true}

# Return's the group's leader
getGroupLeader = (groupId, callback) ->
  query = "START g=node({groupId})
           MATCH leader-[:OWNER]->g
           RETURN leader"
  db.query query, {groupId: groupId}, (err, leader) ->
    database.returnValue err, leader, ((value) -> value[0].leader), callback

# Makes the user leave the group
removeGroupMember = (userId, groupId, callback) ->
  query = "START u=node({userId}), g=node({groupId})
           MATCH u-[r:MEMBER_OF|:IS_MEMBER|:OWNER]-g
           DELETE r"
  db.query query, {userId: userId, groupId: groupId}, callback

# Makes the user leave the group
leaveGroup = (userId, groupId, callback) ->
  getGroupLeader groupId, database.handle callback, (leader) ->
    if (leader.id == userId)
      callback "Leader cannot leave the group", null
    else
      removeGroupUser userId, groupId, callback

# The leader can remove someone from the group
removeFromGroup = (myId, userId, groupId, callback) ->
  if (myId == userId)
    callback "Cannot remove myself. Use leaveGroup instead", null
  else
    getGroupLeader groupId, database.handle callback, (leader) ->
      if (leader.id != myId)
        callback "Only the leader can remove someone from the group"
      else
        removeGroupUser userId, groupId, callback

# Looks up the group, removes all of its events. All users will get this event removed from their subscribed to list
# Pre: the user already has checked that he is authorized to remove the group events
deleteGroupEvents = (groupId, callback) ->
  query = "START g=node({groupId})
           MATCH g-[:ORGANIZES]->event
           WITH event
           MATCH event-[r]-()
           DELETE event, r"
  db.query query, {groupId: groupId}, callback

# Deletes a group from the database
# It cleans up any of the group's data such as events
# Pre: the user is already authenticated to remove the group
deleteGroup = (groupId, callback) ->
  deleteGroupEvents groupId, database.handle callback, ->
    query = "START g=node({groupId})
             MATCH g-[r]-()
             DELETE g, r"
    db.query query, {groupId: groupId}, callback

# Returns all currently existing groups
getAllGroups = (callback) ->
  query = "START r=node({rootId}) MATCH r-[:GROUP]->groups-->group RETURN group"
  db.query query, {rootId: database.rootNodeId}, (err, groups) ->
    f = (data) ->
      value.group.data['id'] = value.group.id for value in data
      return (value.group.data for value in data)
    database.returnValue err, groups, f, callback

# Returns the group with a given GROUPID
# groupId <integer> id of the group
getGroupById = (groupId, callback) ->
  query = "START r=node({rootId}), g=node({groupId})
           MATCH r-[:GROUP]->groups-->g
           RETURN g"
  db.query query, {rootId: database.rootNodeId, groupId: groupId}, (err, groups) ->
    database.returnValue err, groups, ((data) -> data[0].g.data), callback

# Returns the list of events organizes by a given group
getGroupEvents = (groupId, callback) ->
  query = "START r=node({rootId}), g=node({groupId})
           MATCH r-[:GROUP]->groups-->g-[:ORGANIZES]->event
           RETURN event"
  db.query query, {rootId: database.rootNodeId, groupId: groupId}, (err, events) ->
    database.returnValue err, events, ((data) -> (value.event.data for value in data)), callback

exports.createGroup     = createGroup
exports.getAllGroups    = getAllGroups
exports.getGroupById    = getGroupById
exports.getGroupEvents  = getGroupEvents
exports.leaveGroup      = leaveGroup
exports.removeFromGroup = removeFromGroup
exports.deleteGroup     = deleteGroup
exports.joinGroup       = joinGroup
