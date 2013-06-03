union    = require './scrapeUnion.coffee'
database = require '../database/database.coffee'
events   = require '../database/events'

db = database.db

pushToNeo = (config) ->
  # Might need to parse the config file
  database.createNode "SCRAPEDDATA", config, "ORGANIZES", (err, scrapedEvent) ->
    if err
      console.log "Failed creating the event: #{err}"
    else
      events.makePublicEvent scrapedEvent, -> # Made the event public

scrapeAll = ->
  # In case any new relations are added make sure to remove all of them
  query =  "START root=Node({rootNodeId})
            MATCH root-[:SCRAPEDDATA]->scrapeddata-[r]->event
            DELETE event, r"
          
  db.query query, {rootNodeId: database.rootNodeId}, (err, res) ->
    console.log "executed delete. Result:", res
    union.scrape pushToNeo

main = ->
  console.log "Events-scrape: Updating the auto-generated events"
  scrapeAll()

# If the module is run from a script invoke it
if (!module.parent)
  main()