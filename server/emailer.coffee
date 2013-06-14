path = require("path")
templatesDir = path.join(__dirname, "templates")
emailTemplates = require("email-templates")
emailTemplates templatesDir, (err, template) ->
  
  # Render a single email with one template
  locals = pasta: "Spaghetti"
  template "pasta-dinner", locals, (err, html, text) ->

  
  # ...
  
  # Render multiple emails with one template
  locals = [
    pasta: "Spaghetti"
  ,
    pasta: "Rigatoni"
  ]
  Render = (locals) ->
    @locals = locals
    @send = (err, html, text) ->

    
    # ...
    @batch = (batch) ->
      batch @locals, @send

  template "pasta-dinner", true, (err, batch) ->
    for user of users
      render = new Render(users[user])
      render.batch batch

