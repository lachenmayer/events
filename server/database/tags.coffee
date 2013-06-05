database = require('./database.coffee')

db = database.db

createTag = (tagName, callback) ->
  database.createNode "TAGS", {"tagName": tagName} , "TAG", database.handle callback, (tagNode) ->
    callback null, tagNode

findTagNode = (tagName, callback) ->
  query = "START r=node({rootId})
           MATCH r-[:TAG]->tags-->e
           WHERE e.tagName = {tagName}
           RETURN u"
  db.query query, {rootId: database.rootNodeId, tagName: tagName}, database.handle callback, (tags) ->
    callback null, database.returnDataWithId (tags[0])

findOrCreateTag = (tag, callback) ->
  findTagNode tag, (err, tagNode) ->
    if (err)
      callback err, null
    else if !tagNode
      createTag tag, (err, createdTag) ->
        callback err, createdTag

#findSubscribedTags = (user, callback) ->
#  query = "START r=node({rootId}), e=node({eventId})
#             MATCH r-[:TAG]->events-->e<-[:SUBSCRIBED_TO]-u<--users<-[:USERS]-r
#             RETURN u"
#  db.query query, {rootId: database.rootNodeId, eventId: eventId}, database.handle callback, (users) ->
#  callback null, database.returnListWithId (n.u for n in users)
#  callback null, null

findAllTags = (callback) ->
  query =   "START r=node({rootId})
             MATCH r-[:TAG]->tags-->e
             RETURN e"
  db.query query, {rootId: database.rootNodeId}, database.handle callback, (tags) ->
    callback null, database.returnListWithId(tags)


findPopularTags = (callback) ->
  callback null, null

attachTag = (node, tagNode, callback) ->
  database.makeRelationship node, tagNode, "TAGGED_WITH", database.handle callback, ->
    callback null, tagNode

exports.createTag = createTag
exports.findTagNode = findTagNode
exports.findOrCreateTag = findOrCreateTag
# exports.findSubscribedTags = findSubscribedTags
exports.findPopularTags = findPopularTags
exports.attachTag = attachTag
