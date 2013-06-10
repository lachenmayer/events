Backbone        = require '../solutionio-backbone'
chrono          = require '../chrono'
Bacon           = require '../baconjs'
moment          = require '../moment'

exports.CreateEventView = Backbone.View.extend

  template: require './create-event-view'

  initialize: ->

  render: ->
    @$el.html @template
    @parseDates()

  parseDates: ->
    $when = @$el.find '.when'
    $date = @$el.find '.date'
    dates = $when.asEventStream('keyup')
                 .throttle(300)
                 .map(-> $when.val())
                 .skipDuplicates()
                 .map((text) -> moment(chrono.parseDate text))
                 .skipDuplicates()
    dates.onValue (date) ->
      $date.text(if date? then date.format() else '')
