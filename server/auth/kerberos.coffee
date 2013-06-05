###
  Auth/Kerberos
  Library that provides kerberos authentication for the passport framework
###
krb5          = require 'node-krb5'

exports.authenticate = (username, password, callback) ->
  krb5.authenticate username + '@IC.AC.UK', password, callback