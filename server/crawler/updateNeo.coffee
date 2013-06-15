union    = require './scrapeUnion.coffee'
imperial = require './imperialCalendar'
custom   = require './customData'
database = require '../database/database.coffee'
events   = require '../database/events'
tagData  = require '../database/tags'

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
        console.log "Attach tags"
        for tag in tags
          tagData.findOrCreateTag tag, (err, createdTag) ->
            console.log "Attach tag: #{tag}, err: #{err}, node: #{scrapedEvent}, tagNode: #{createdTag}"
            if (err)
              console.log "Error: #{err}"
            else
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
      custom.scrape pushToNeo

cleanTags = (handler) ->
  query = "START root=node({rootId})
           MATCH root-[:TAGS]->()-->t
           WHERE NOT(u-[:TAGGED_WITH]->t)
           WITH t
           MATCH t-[r]-()
           DELETE t, r"
  db.query query, {}, (err, res) ->
    console.log "Submitted the query"

main = ->
  console.log "Events-scrape: Updating the auto-generated events"
  cleanTags scrapeAll

# If the module is run from a script invoke it
if (!module.parent)
  main()
