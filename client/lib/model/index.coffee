event = require './lib/event'
events = require './lib/events'
tag = require './lib/tag'
tags = require './lib/tags'

# Add the Event exports
exports[key] = val for key, val of event
exports[key] = val for key, val of events
exports[key] = val for key, val of tag
exports[key] = val for key, val of tags
