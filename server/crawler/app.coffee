request = require("request")
cheerio = require('cheerio')
url     = require('url')


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


followEvent = (details, u) ->
	# Should fetch the website and get the details
	fetchAndExecute u, ($) ->
		location      = $(".whatsoneventpagevenue").text()
		description   = $(".whatsoneventpagedesc").text()
		imageAbsolute = u + "/image"
		details["location"]    = location
		details["description"] = description
		details["image"] = imageAbsolute
		details["source"] = "scrapedData"
		console.log details


fetchEvent = (year, month, $) ->
	events = []
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

			followEvent details, u

console.log "Starting to fetch the website"

# A method that fetches data from the imperial website
fetchUnionEvent = (year, month) ->
	fetchAndExecute EVENTS_SITE(year, month), ($) ->
		fetchEvent year, month, $

fetchAndExecute = (uri, handler) ->
	request {
		uri: uri
	}, (error, response, body) ->
		$ = cheerio.load(body)
		console.log "Parsing #{uri}"
		handler $
		console.log "Paresed #{uri}"

# Invoking of an event
fetchUnionEvent "2013", "06"

# # A repeater function
# repeater = (handle, timeout) ->
# 	handler = ->
# 		handle()
# 		setTimeout handler, timeout
# 	handler()