###
  A library allowing comments interaction
###
database = require './database'
moment   = require 'moment'

db = database.db


class CommentsModel
  relation: "COMMENT"

  constructor: ->
    @created = false

  initialize: (@originNode, comment, @author, @username) ->
    @data =
      comment: comment
      author:  @username
      createDate: moment().unix()

  toModel: (commentNode) ->
    model = new CommentsModel()
    model.data    = commentNode.data
    model.id      = commentNode.id
    model.author  = commentNode.data.author
    model.created = true

    model.data.id = model.id
    return model

  getListFromOrigin: (id, callback) ->
    query = "START o=node({originId})
             MATCH o-[:#{@relation}]->c
             RETURN c"
    db.query query, {originId: id}, database.handle callback, (comments) =>
      models = (@toModel(comment.c) for comment in comments)
      callback null, models

  # Gets a new node from a gievn id
  getFromId: (id, callback) ->
    query = "START i=node({commentId})
             RETURN i"
    db.query query, {commentId: id}, database.handle callback, (value) =>
      model = @toModel value[0].i
      callback null, model

  save: (callback) ->
    if not @created
      @createNew database.handle callback, (value) ->
        @created = true
        callback null, value
    else
      @updateNode callback

  # Updates the node
  updateNode: (callback) ->
    @data.updateDate = moment().unix()
    query = "START o=node({commentId})
             SET o={values}
             RETURN o"
    db.query query, {commentId: @id, values: @data}, database.handle callback, (v) ->
      callback null, v[0].o.id

  # Saves the given node and returns its newly created id
  createNew: (callback) ->
    @data.createDate = moment().unix()
    query = "START o=node({originId}), a=node({userId})
             CREATE o-[:#{@relation}]->(c {data})<-[:COMMENTED_BY]-a
             RETURN ID(c) as id"
    db.query query, {originId: @originNode, userId: @author, data: @data}, database.handle callback, (comments) ->
      @id = comments[0].id
      callback null, @id

  # Deletes the node and all of the connecting relations
  delete: (callback) ->
    query = "START c=node({eventId})
             MATCH c-[r]-()
             DELETE c, r"
    db.query query, {eventId: @id}, database.handle callback, ->
      callback null, {success: true}

getCommentFromId = (commentId, callback) ->
  model = new CommentsModel()
  model.getFromId commentId, database.handle callback, (model) ->
    callback null, model.data

getCommentsFromEvent = (originId, callback) ->
  model = new CommentsModel()
  model.getListFromOrigin originId, database.handle callback, (models) ->
    callback null, (model.data for model in models)

modifyComment = (commentId, newData, callback) ->
  model = new CommentsModel()
  model.getFromId commentId, database.handle callback, (model) ->
    for key, value of newData
      model.data[key] = value
    model.save callback

deleteComment = (commentId, callback) ->
  model = new CommentsModel()
  model.getFromId commentId, database.handle callback, (comment) ->
    comment.delete callback

addNewComment = (eventId, authorId, data, callback) ->
  comment = new CommentsModel()
  comment.initialize eventId, data.comment, authorId, data.author
  comment.save callback

# Defining the publicly available functions
exports.deleteComment        = deleteComment
exports.modifyComment        = modifyComment
exports.addComment           = addNewComment
exports.getCommentFromId     = getCommentFromId
exports.getCommentsFromEvent = getCommentsFromEvent
