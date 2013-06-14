database = require('./database.coffee')
moment = require 'moment'
Q = require 'Q'

JobIDs = 
  runScraper : 100
  emailNotification : 105


db = database.db

    # Node Schema
    # JOBS-[:NEXT_JOB]->FirstJob-[:NEXT_JOB]->SecondJob -[:NEXT_JOB]->ThirdJob
    # Where FirstJob.runTimestamp < SecondJob.runTimestamp
    #--Job JSON
    # runTimestamp - <required>
    # jobId        - <required>
    # jobArguments - <required>
    # jobName      - <optional>
    # repeatDiff   - <optional>
    # priority     - <optional>
    #--


removeJob = (jobId, callback) ->
  query = "START event=node({jobId})
           MATCH jobRoot-[r:JOB]->job
           DELETE job, r"
  db.query query, {jobId: jobId}, callback

addJob = (jobDescription, callback) ->
  console.log "Job: #{jobDescription.toString()}\nFunction: #{jobFunction.toString()}"
  # Make sure jobDescription has all the required  fields
  if not jobDescription.runTimestamp\
  or not jobDescription.jobId or not jobDescription.jobArguments
    callback "Insufficient Arguments", null
  values = database.serializeData jobDescription
  query = "START root=node({rootId})
           CREATE (j {#{values}}), jobs-[:JOB]->j, root-[:JOBS]->jobs-[:JOB]->j
           RETURN j"
  db.query query, {rootId: database.rootNodeId}, database.handle callback, (job) ->
    callback null, job[0].j.id

  callback null, null

getAllJobs = (callback) ->
  query = "START root=node({rootId})
           MATCH root-[:JOBS]->jobs-->j
           RETURN j
           ORDER BY j.runTimestamp"
  db.query query, {rootId: database.rootNodeId}, database.handle callback, (jobs) ->
    callback null, JOBS

checkJobs = () ->
  callTimestamp = moment().unix()
  getAllJobs (err, jobs) ->
    if err or not jobs
      console.log "err: #{err}\njobs: #{jobs}"
    else
      for job in jobs
        if job.runTimestamp < callTimestamp
          runJob job, () ->
        else break

emailNotifier = (job, callback) ->
  console.log job

scraper = (job, callback) ->
  console.log job


runJob = (job, callback) ->
  switch job.jobId
    when runScraper then scraper job, postJob
    when emailNotification then emailNotifier job, postJob
    else console.log "Unknown job id.. Dumping <#{job}>"
  

postJob = (err, job) ->
  console.log "Err: <#{err}>, arg: <#{arg}>"
  removeJob job
  if job.repeatDiff
    job.runTimestamp = moment().unix() + job.repeatDiff
    addJob job

exports.addJob = addJob
exports.checkJobs = checkJobs