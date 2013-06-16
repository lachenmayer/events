###
  This is the file that contains dummy data that can be added to the database
###
moment = require 'moment'


# List of all of the events that need to be added to the database
# TODO: add the list of the presentations.
# This way one can quickly set up the system
events = [
  {
    name: "My custom event"
    host: "Me"
    description: "Something new finally"
    location: "Location of the event"
    url: "my personal url"
    image: ""
    date: moment().unix()
    type: "type3"
    tags: ["newTag"]
    source: "scrapedData"
  }
]

scrape = (handler) ->
  for event in events
    handler event

exports.scrape = scrape