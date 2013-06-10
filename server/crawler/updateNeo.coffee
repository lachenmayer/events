union    = require './scrapeUnion.coffee'
imperial = require './imperialCalendar'
database = require '../database/database.coffee'
events   = require '../database/events'
tagData     = require '../database/tags'

db = database.db

pushToNeo = (config) ->
  # Lookup tags, and add them as relationships to tag nodes
  tags = config["tags"]
  # delete config["tags"] # Replicating Data for now to ease speed
  database.createNode "SCRAPEDDATA", config, "ORGANIZES", (err, scrapedEvent) ->
    if err
      console.log "Failed creating the event: #{err}"
    else
      events.makePublicEvent scrapedEvent, -> # Made the event public
        for tag in tags
          tagData.findOrCreateTag tag, (err, createdTag) ->
            if (err)
              console.log "Error: #{err}"
            else
              # attach to this tag
              tagData.attachTag scrapedEvent, createdTag, ->


scrapeAll = ->
  # In case any new relations are added make sure to remove all of them
  query =  "START root=Node({rootNodeId})
            MATCH root-[:SCRAPEDDATA]->scrapeddata-->event
            WITH event
            MATCH event-[r]-()
            DELETE event, r"
  db.query query, {rootNodeId: database.rootNodeId}, (err, res) ->
    if err
      console.log "Error #{err}"
    else
      console.log "executed delete. Result:", res
      union.scrape pushToNeo
      imperial.scrape pushToNeo

main = ->
  console.log "Events-scrape: Updating the auto-generated events"
  scrapeAll()

# If the module is run from a script invoke it
if (!module.parent)
  main()