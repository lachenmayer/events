for model in ['event', 'events', 'tag', 'tags', 'user']
  exports[key] = val for key, val of require "./lib/#{model}"
