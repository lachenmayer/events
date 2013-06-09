strings =
  newEvent:
    en: 'New Event'
  upcomingEvents:
    en: 'Upcoming Events'
  yesterday:
    en: 'Yesterday'
  today:
    en: 'Today'
  tomorrow:
    en: 'Tomorrow'
  tags:
    en: 'Tags'
  eventViewTitle:
    en: 'Event Details'
  loginViewTitle:
    en: 'Login'

exports.lang = (language) ->
  return this if @language is language
  @language = language
  for string of strings
    exports[string] = strings[string][language]
  this

