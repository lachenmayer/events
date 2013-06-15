for model in ['event', 'events', 'tag', 'tags', 'user', 'icalURL', 'comment', 'comments']
  exports[key] = val for key, val of require "./lib/#{model}"
