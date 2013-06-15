exec = require("child_process").exec

runLDAP = (uri, callback) ->
  child = exec "ldapsearch -h addressbook.imperial.ac.uk -x -b \"o=Imperial College\" uid=#{uri}", (error, stdout, stderr) ->
    console.log "stderr: " + stderr if stderr.length > 0
    console.log "exec error: " + error  if error isnt null
    callback null, stdout
  
getInfo = (uri, callback) ->
  runLDAP uri, (err, stdout) ->
    if err or not stdout
      callback err, null
    l1 = stdout.split '\n'
    info = {}
    for line in l1
      keyval = line.split ':'
      if keyval.length != 2
        continue
      info[keyval[0]]=keyval[1][1..]
    console.log "getInfo: #{uri}"
    callback null, info

getUserInfo = (uri, callback) ->
  getInfo uri, (err, info) ->
    if err or not info
      console.log "No User Information Found for user: #{uri}"
      callback err, null
    else
      userInfo =
        "displayName" : info["displayName"],
        "surname" : info["sn"],
        "uid" : info["uid"],
        "type" : info["employeeType"],
        "email" : info["mail"],
        "givenName" : info["givenName"],
        "title": info["title"]
      callback null, userInfo


exports.getAllInfo = getInfo
exports.getUserInfo = getUserInfo
