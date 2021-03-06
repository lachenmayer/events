database = require('./database.coffee')
_ = require 'underscore'

db = database.db

createTag = (tagName, callback) ->
  # console.log "createTag"
  database.createUniqueNode "TAGS", {"tagName": tagName} , "TAG", database.handle callback, (tagNode) ->
    # console.log "Creating Tag: #{tagNode}, #{tagName}"
    callback null, tagNode

findTagNode = (tagName, callback) ->
  query = "START r=node({rootId})
           MATCH r-[:TAGS]->tags-->t
           WHERE t.tagName = {tagName}
           RETURN t"
  db.query query, {rootId: database.rootNodeId, tagName: tagName}, database.handle callback, (tags) ->
#    (console.log t.t) for t in tags
    if tags.length > 0
      # console.log "Tag Found #{tagName}"
      callback null, tags[0].t
    else
      # console.log "Tag Not Found #{tagName}"
      callback null, null

findOrCreateTag = (tag, callback) ->
  findTagNode tag, (err, tagNode) ->
    if err
      # console.log "findTag Fail"
      callback err, null
    else if not tagNode
      createTag tag, (err, createdTag) ->
        callback err, createdTag
    else 
      callback null, tagNode

findEventTags = (eventNodeId, callback) ->
  query = "START r=node({eventNodeId})
           MATCH r-[:TAGGED_WITH]->tag
           RETURN tag"
  db.query query, {eventNodeId: eventNodeId}, (err, tags) ->
    database.returnValue err, tags, ((data) -> database.returnListWithId (tag.e for tag in data)), callback

# Finds the list of tags subscribed by a node
findSubscribedTags = (nodeId, callback) ->
  query = "START r=node({rootId}), u=node({userId})
            MATCH r-[:TAGS]->tags-[:TAG]->t<-[:SUBSCRIBED_TO]-u<--users<-[:USERS]-r
            RETURN t"
  db.query query, {rootId: database.rootNodeId, userId: nodeId}, database.handle callback, (users) ->
    callback null, (n.t.id for n in users)

getAllTags = (callback) ->
  query = "START r=node({rootId})
           MATCH r-[:TAGS]->tags-->t-[:TAGGED_WITH]-c
           RETURN t, count(c)"
  db.query query, {rootId: database.rootNodeId}, database.handle callback, (tags) ->
    (t.t.data['count'] = t['count(c)'] for t in tags)
    # console.log JSON.stringify(t.t.data)+' --- '+t['count(c)'] for t in tags
    callback null, database.returnListWithId (t.t for t in tags)

# Check if user is subscribed to an tag
isSubscribed = (userId, nodeId, callback) ->
  query = "START r=Node({rootId}), m=Node({userId}), event=Node({eventId})
           MATCH r-[:USERS]->u-->m-[:MEMBER_OF*0..]->g-[:ORGANIZES|SUBSCRIBED_TO]->tag
           RETURN tag"
  db.query query, {rootId: database.rootNodeId, userId: userId, eventId: nodeId}, (err, data) ->
    console.log "err:", err, "event:",data, "data.length:", data.length
    # console.log "isSubscribedToEvent:", event, (event and event.event.length > 0)
    callback null, {isSubscribed: (data and data.length > 0)}



getUserTags = (userId, callback) ->
  findSubscribedTags userId, database.handle callback, (subscribed) ->
    getAllTags database.handle callback, (tags) ->
      for tag in tags
        tag.subscribed = tag.id in subscribed

      callback null, tags

findPopularTags = (callback) ->
  callback null, null

attachTag = (node, tagNode, callback) ->
  # console.log "Attaching tag: #{node}, #{tagNode}"
  database.makeRelationship node, tagNode, "TAGGED_WITH", database.handle callback, ->
    # console.log "Attached tag: #{tagNode}"
    callback null, tagNode

exports.createTag = createTag
exports.findTagNode = findTagNode
exports.findOrCreateTag = findOrCreateTag
exports.getAllTags = getAllTags
# exports.findSubscribedTags = findSubscribedTags
exports.findPopularTags = findPopularTags
exports.attachTag = attachTag
exports.getUserTags = getUserTags
