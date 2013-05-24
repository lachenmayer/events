module.exports = (app) ->

  app.get '/', (req, res) ->
    res.render 'index',
      title: 'cool beans man'

