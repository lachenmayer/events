Backbone        = require '../solutionio-backbone'
chrono          = require '../chrono'
Bacon           = require '../baconjs'
moment          = require '../moment'
Strings         = require('../strings').lang 'en'

id = (x) -> x

exports.CreateEventView = Backbone.View.extend

  template: require './create-event-view'

  inputs: ['what', 'description', 'when', 'where']

  render: ->
    @$el.html @template
    @elems()
    @parseDates()
    @validateForm()
    @onSubmission()

  elems: ->
    for elem in @inputs.concat 'date', 'submit'
      this[elem] = @$el.find ".#{elem}"

  parseDates: ->
    dates = @when.asEventStream('keyup')
                 .throttle(300)
                 .map(=> @when.val())
                 .skipDuplicates()
                 .map((text) -> moment(chrono.parseDate text))
                 .skipDuplicates()
    dates.onValue (date) =>
      @parsedDate = date
      @date.text(if date? then date.format(Strings.dateTimeFormat) else '')
    @validDates = dates.filter (date) -> date?

  validateForm: ->
    @submitButtonClick = @submit.asEventStream 'click'
    inputsStartEditing = for input in @inputs
      this[input].asEventStream('keyup').take(2)
    afterFirstSubmission = inputsStartEditing.concat @submitButtonClick,
                                                     @validDates
    afterFirstSubmission = Bacon.mergeAll afterFirstSubmission
    validateNow = @submitButtonClick.take(1).concat afterFirstSubmission
    valids = validateNow.map => @validFields(@inputValues())
    valids.onValue (fields) => @highlightInvalidFields fields

  onSubmission: ->
    @submitButtonClick.doAction '.preventDefault'
    validSubmission = @submitButtonClick.map(=>
      @allFieldsValid(@validFields(@inputValues()))).filter(id)
    validSubmission.onValue (val) =>
      console.log "SUBMIT"
      console.log @inputValues()

  inputValues: ->
    what: @what.val()
    description: @description.val()
    when: @when.val()
    date: @parsedDate?.unix()
    where: @where.val()

  # (field: value) -> (field: bool)
  validFields: (fields) ->
    for input in @inputs
      fields[input] = fields[input] isnt ''
    fields.date = fields.date?
    fields

  # (field: bool) -> bool
  allFieldsValid: (fields) ->
    for field of fields
      return false unless fields[field]
    true

  # (field: bool) -> ()
  highlightInvalidFields: (valid) ->
    for input in @inputs
      @highlight input, valid[input]
    unless valid.date
      @highlight 'when', false

  highlight: (field, valid) ->
    this[field].toggleClass 'error', (not valid)

