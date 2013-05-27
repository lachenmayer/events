request = require 'request'
cheerio = require 'cheerio'
url     = require 'url'
moment  = require 'moment'



# fetchUnionEvent

#

exports.scrape = (handler) ->
	# Scrape all of the dates for the event
	now = moment()
	lastMonth = moment().subtract('month', 1)
	nextMonth = moment().add('month', 1)
	fetchUnionEvent lastMonth, handler
	fetchUnionEvent now, handler
	fetchUnionEvent nextMonth, handler

# Defines the url for the union website
UNION_URL = "https://www.imperialcollegeunion.org/whats-on"
EVENTS_SITE = (year, month) ->
	return "#{UNION_URL}/month/#{year}/#{month}"


parseMessage = (message, time) ->
	split = message.split("@").map (el) -> el.trim()
	return {
		name: split[0]
		host: ""
		location: if split.length > 1 then split[1] else ""
		time: time
	}


getDate = (year, month, day, time) ->
	return "#{year}/#{month}/#{day} #{time}"


followEvent = (details, u, handler) ->
	# Should fetch the website and get the details
	fetchAndExecute u, ($) ->
		location      = $(".whatsoneventpagevenue").text()
		description   = $(".whatsoneventpagedesc").text()
		imageAbsolute = u + "/image"
		details["location"]    = location
		details["description"] = description
		details["image"] = imageAbsolute
		details["source"] = "scrapedData"
		handler details


fetchEvent = (year, month, $, handler) ->
	$("table.calendar .calendar-day").each (index, td) ->
		day = $(td).find(".day-number").text()
		$(td).find(".calendar-event li").each (index, e) ->
			eventType = $(e).attr('class')
			time   = $(e).find("a").children().first().text()
			$(e).find("a").children().remove()
			message   = $(e).find("a").text()
			config = parseMessage message, time
			relativeUrl = $(e).find("a").attr('href')
			u = url.resolve EVENTS_SITE(year, month), relativeUrl

			details = {
				name: config.name
				host: config.host
				url: u
				location: config.location
				# description: details.description
				date: getDate year, month, day, config.time
				type: eventType
			}

			followEvent details, u, handler

# A method that fetches data from the imperial website
fetchUnionEvent = (moment, handler) ->
	fetchAndExecute EVENTS_SITE(moment.year(), moment.month() + 1), ($) ->
		fetchEvent moment.year(), moment.month() + 1, $, handler

fetchAndExecute = (uri, handler) ->
	request {
		uri: uri
	}, (error, response, body) ->
		$ = cheerio.load(body)
		console.log "Parsing #{uri}"
		handler $
		console.log "Paresed #{uri}"