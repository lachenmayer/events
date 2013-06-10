feedparser = require 'feedparser'
request    = require 'request'
utils      = require '../utils'
moment     = require 'moment'

IMPERIAL_URI = 'http://www3.imperial.ac.uk/imperialnewsevents/eventsfront?pid=2551_175458356_2551_76327754_76327754'

crawlNews = (article, handler) ->
  data =
    name: article.title
    host: article['imperialnewsevents:source']['#']
    url: article.link
    location: article['imperialnewsevents:location']['#']
    date: moment(article['imperialnewsevents:event_start_date']['#']).unix()
    type: ''
    description: article.description
    image: article['imperialnewsevents:mediumimage']['#']
    source: 'scrapedData'
    tags: ['Imperial']

  console.log "Fetched #{data.url}"
  handler data

crawlRSS = (handler) ->
  request(IMPERIAL_URI).pipe(new feedparser()).on 'article', (article) ->
    crawlNews article, handler

exports.scrape = crawlRSS