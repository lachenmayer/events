###
  Provides the iCal interoperability
###
jsDAV  = require './fixlib/jsDAV/lib/VObject/component'
prop   = require './fixlib/jsDAV/lib/VObject/property'
moment = require 'moment'
database = require './database/database'
users  = require './database/users'
events  = require './database/events'
crypto = require 'crypto'

db = database.db

TIME_FORMAT = "YYYYMMDDTHHmmss"
ICAL_ID_STRING_LENGTH = 30
ICAL_RELATION = "ICALURL"

pushValue = (e, name, value) ->
  if value?
    e.add name, value

class Event

  constructor: (@uid, @start, @summary, @location, @description) ->

  toVObject: ->
    vobject = jsDAV.create('VEVENT')
    startStamp = moment.unix(@start)

    vobject.add 'UID', @uid
    vobject.add 'STSTAMP', startStamp.format(TIME_FORMAT)
    vobject.add 'DTSTART', startStamp.format(TIME_FORMAT)
    if @end?
      vobject.add 'DTEND', moment.unix(@end).format(TIME_FORMAT)
    else
      vobject.add 'DTEND', startStamp.add('h', 1).format(TIME_FORMAT)
    pushValue vobject, 'LOCATION', @location
    vobject.add 'SUMMARY', @summary
    vobject.add 'DESCRIPTION', @description.replace("\n", '').replace("\r", '')
    vobject.add 'SEQUENCE', "0"

    return vobject

createICal = (prodid, events) ->
  vcal = jsDAV.create('VCALENDAR')
  vcal.add "METHOD", "PUBLISH"
  vcal.add 'VERSION', '2.0'
  vcal.add 'PRODID', "-//group125//eventsList//EN"
  vcal.add 'CALSCALE', 'GREGORIAN'
  for e in events
    if not e.tagName?
      vcal.add eventToVObject(e)
  return vcal

# Modifies the event format provided by the database into the ical format
eventToVObject = (event) ->
  startTime = moment.unix(event.date).format(TIME_FORMAT)
  uid = "#{startTime}-#{event.id}"
  event = new Event(uid, event.date, event.name, event.location, event.description)
  return event.toVObject()

toVCalendar = (prodId, events) ->

  vcal = createICal prodId, events
  return vcal.serialize()

# Returns the ical url for a given user
getICalURL = (nodeId, callback) ->
  query = "START n=node({nodeId})
           MATCH n-[:#{ICAL_RELATION}]->i
           RETURN i"
  db.query query, {nodeId: nodeId}, database.handle callback, (iUrl) ->
    if (iUrl.length == 0)
      callback "User does not have iCAL activated", null
    else
      callback null, iUrl[0].i.data

# Returns the user id that has a given ICALID
getICalUser = (icalId, callback) ->
  query = "START r=node({rootId})
           MATCH r-[:ICAL]->icals-->i
           WHERE i.icalId = {icalId}
           RETURN i"
  db.query query, {rootId: database.rootNodeId, icalId: icalId}, database.handle callback, (idNodes) ->
    if (idNodes.length == 0)
      callback "A given ical url does not exist", null
    else
      callback null, idNodes[0].i.data.userId

getICal = (icalId, callback) ->
  getICalUser icalId, database.handle callback, (userId) ->
    users.getUserEvents userId, database.handle callback, (events) ->
      callback null, toVCalendar("prodid", events)

# Removes the ICal url for the user
removeICalURL = (nodeId, callback) ->
  query = "START n=node({nodeId})
           MATCH n-[:#{ICAL_RELATION}]->i
           WITH i
           MATCH i-[r]-()
           DELETE i, r"
  db.query query, {rootId: database.rootNodeId, nodeId: nodeId}, database.handle callback, ->
    callback null, {success: true}

# Should create a random string of length STRING_LENGTH
# Make sure no other ical url with this string already exists
setUniqueID = (callback) ->
  crypto.randomBytes ICAL_ID_STRING_LENGTH, (ex, buf) ->
    newId = buf.toString('hex')
    getICalUser newId, (err) ->
      if err
        # Success: the key does not exist
        callback null, newId
      else
        # Failure: the key already exists in the database
        setUniqueID callback

setICalURL = (nodeId, newId, callback) ->
  removeICalURL nodeId, database.handle callback, ->
    data = database.serializeData {icalId: newId, userId: nodeId}
    query = "START r=node({rootId}), n=node({nodeId})
             MATCH r-[:ICAL]->icals
             CREATE (i {#{data}}), icals-[:ICAL]->i, n-[:#{ICAL_RELATION}]->i
             RETURN i"
    db.query query, {rootId: database.rootNodeId, nodeId: nodeId}, database.handle callback, (values) ->
      if (values.length == 0)
        callback "Could not set the URL", null
      else
        callback null, newId

# Creates an ICal url for the user
# In case the url removes the previous one and craetes a new one
createICalURL = (nodeId, callback) ->
  setUniqueID database.handle callback, (newId) ->
    setICalURL nodeId, newId, callback


exports.createICalURL = createICalURL
exports.getICalURL    = getICalURL
exports.getICal       = getICal
exports.removeICalURL = removeICalURL