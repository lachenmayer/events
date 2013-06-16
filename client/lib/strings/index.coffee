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
  dateFormat:
    en: 'dddd, MMMM Do'
  dateTimeFormat:
    en: 'dddd, MMMM Do [at] ha'
  notFoundTitle:
    en: 'Page not found'
  firstTime:
    en: 'Set up your app'
  setupGmail:
    en: 'Synchronize events with Gmail'
  setupOutlook:
    en: 'Synchronize events with Outlook'
  subscribedEvents:
    en: 'Subscribed events'

exports.lang = (language) ->
  return this if @language is language
  @language = language
  for string of strings
    exports[string] = strings[string][language]
  this

