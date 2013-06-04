###
  Main authentication library
  Chooses the correct authenticator depending on the username 
###
authKerberos = require './auth/kerberos'

# Returns whether a given username is an imperial username
isImperialUsername = -> true

authenticate = (username, password, callback) ->
  if isImperialUsername(username)
    authKerberos.authenticate username, password, callback
  else
    callback "Currently cannot authenticate non Imperial users", null

exports.authenticate = authenticate