###
  This is the file that contains dummy data that can be added to the database
###
moment = require 'moment'


values = [
  ["Fire Alpaca", 19, ["Game"], "2013/06/17 10:00"]
  ["Event Management", 3, ["Tool", "Events", "Management"], "2013/06/17 10:30"]
  ["Context (Geographical News)", 29, ["Tool", "News"], "2013/06/17 11:00"]
  ["Huzzah!", 16, ["Game"], "2013/06/17 11:30"]
  ["Imperial Battles", 9, ["Game"], "2013/06/17 12:00"]
  ["Space", 27, ["Tool", "Piazza"], "2013/06/17 12:30"]
  ["Online Owari", 2, ["Game"], "2013/06/17 14:00"]
  ["Blast City", 37, ["Game"], "2013/06/17 14:30"]
  ["PenWars", 4, ["Multiuser", "Writing"], "2013/06/17 15:00"]
  ["Food Mill", 20, ["Tool", "Aid"], "2013/06/17 15:30"]
  ["Cops and Robbers", 17, ["Game"], "2013/06/17 16:00"]
  ["MLC", 11, [], "2013/06/17 16:30"]
  ["Wandrits", 13, ["Game"], "2013/06/18 10:00"]
  ["Rural Cloud", 8, ["Haskell", "Challenge"], "2013/06/18 10:30"]
  ["(tba)", 38, [], "2013/06/18 11:00"]
  ["Syndicate/Sweepstake Management", 23, [], "2013/06/18 11:30"]
  ["PositionFridge", 15, ["Noticeboard"], "2013/06/18 12:00"]
  ["Project Management", 1, ["PMS"], "2013/06/18 12:30"]
  ["Discharged", 31, ["Game"], "2013/06/18 14:30"]
  ["Fumon", 36, ["Game"], "2013/06/18 15:00"]
  ["Quilt", 5, ["Bookmark"], "2013/06/18 15:30"]
  ["EventSpace", 6, ["Events", "Tool"], "2013/06/18 16:00"]
  ["Family Ties", 28, ["Social", "Elderly"], "2013/06/18 16:30"]
  ["Online Gaming Platform", 30, ["Game"], "2013/06/19 10:00"]
  ["GPS Minesweeper", 35, ["Game"], "2013/06/19 10:30"]
  ["Hands Up", 22, ["Education"], "2013/06/19 11:00"]
  ["Soul Wizards", 10, ["Game"], "2013/06/19 11:30"]
  ["Flipper Flopper", 33, ["Game"], "2013/06/19 12:00"]
  ["Tour Challenge", 25, [], "2013/06/19 12:30"]
  ["Email Privacy", 14, [], "2013/06/20 10:00"]
  ["Debt Tracket", 32, [], "2013/06/20 10:30"]
  ["Story Board", 24, [], "2013/06/20 11:00"]
  ["Gunship Galaxy", 7, ["Game"], "2013/06/20 11:30"]
  ["Timefeed", 21, [], "2013/06/20 12:00"]
  ["Legend of Sapphire", 34, ["Game"], "2013/06/20 14:00"]
  ["Freestyle Typist", 18, ["Game"], "2013/06/20 14:30"]
  ["Sharemarks", 12, [], "2013/06/20 15:00"]
]

buildEvent = (name, groupId, tags, date) ->
  name: name
  host: "Group #{groupId}"
  description: name
  location: "Room 311, Huxley Building"
  url: "www.imperial.ac.uk"
  image: ""
  date: moment(date).unix()
  type: ""
  tags: [].concat [tags, ["DoC", "Presentations"]]...
  source: "scrapedData"

# List of all of the events that need to be added to the database
# TODO: add the list of the presentations.
# This way one can quickly set up the system
eventData = (buildEvent(value...) for value in values)

events = [].concat (eventData)...

scrape = (handler) ->
  for event in events
    handler event

exports.scrape = scrape