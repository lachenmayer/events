database = require('./database.coffee')

db = database.db

createTag = (tagName, callback) ->
  database.createNode "TAGS", {"tagName": tagName} , "TAG", database.handle callback, (tagNode) ->
    console.log "Creating Tag: #{tagNode}"
    callback null, tagNode

findTagNode = (tagName, callback) ->
  query = "START r=node({rootId})
           MATCH r-[:TAGS]->tags-->t
           WHERE t.tagName = {tagName}
           RETURN t"
  db.query query, {rootId: database.rootNodeId, tagName: tagName}, database.handle callback, (tags) ->
    #console.log "Tag Found #{tags} #{tags[0].t} #{tags.t}"
#    (console.log t.t) for t in tags
    if tags.length > 0
      callback null, tags[0].t
    else
      callback null, null

findOrCreateTag = (tag, callback) ->
  findTagNode tag, (err, tagNode) ->
    if err
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
           MATCH r-[:TAGS]->tags-->t
           RETURN t"
  db.query query, {rootId: database.rootNodeId}, database.handle callback, (tags) ->
    callback null, database.returnListWithId (t.t for t in tags)


getUserTags = (userId, callback) ->
  findSubscribedTags userId, database.handle callback, (subscribed) ->
    getAllTags database.handle callback, (tags) ->
      for tag in tags
        tag.subscribed = tag.id in subscribed

      callback null, tags

findPopularTags = (callback) ->
  callback null, null

attachTag = (node, tagNode, callback) ->
  database.makeRelationship node, tagNode, "TAGGED_WITH", database.handle callback, ->
    console.log "Attaching tag"
    callback null, tagNode

exports.createTag = createTag
exports.findTagNode = findTagNode
exports.findOrCreateTag = findOrCreateTag
exports.getAllTags = getAllTags
# exports.findSubscribedTags = findSubscribedTags
exports.findPopularTags = findPopularTags
exports.attachTag = attachTag
exports.getUserTags = getUserTags
