for model in ['event', 'events', 'tag', 'tags']
  exports[key] = val for key, val of require "./lib/#{model}"
