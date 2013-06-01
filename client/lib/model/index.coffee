event = require './lib/event'
events = require './lib/events'

# Add the Event exports
exports[key] = val for key, val of event
exports[key] = val for key, val of events
