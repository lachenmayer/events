event = require './lib/event'
eventlist = require './lib/eventlist'

# Add the Event exports
exports[key] = val for key, val of event
exports[key] = val for key, val of eventlist