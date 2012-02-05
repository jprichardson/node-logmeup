request = require('superagent')
path = require('path')
fs = require('fs')
{EventEmitter} = require('events')
require('string')

exports = module.exports

defaultLogger = null

class LogMeUp extends EventEmitter
  logExists: false
  constructor: (@baseUrl, @collection, @app) ->

  create: (callback) ->
    url = "#{@baseUrl}/log/#{@collection}/#{@app}" 
    request.put(url).end (res) =>
      if res.text.startsWith("Error:") or res.status isnt 200
        if res.text.contains('exists') then @logExists = true
        callback(new Error(res.text), null)
      else
        @logExists = true
        callback(null, res.text)


  delete: (callback) ->
    url = "#{@baseUrl}/log/#{@collection}/#{@app}" 
    request.del(url).end (res) =>
      if res.text.startsWith("Error:") or res.status isnt 200
        callback(new Error(res.text), null)
      else
        @logExists = false
        callback(null, res.text)


  log: (data, callback) ->
    url = "#{@baseUrl}/log/#{@collection}/#{@app}"
    newData = null
    mime = ''
    if typeof(data) is 'object'
      newData = data
      mime = 'application/json'
    else
      try
        newData = JSON.parse(data)
        mime = 'application/json'
      catch error
        newData = data: data
        mime= 'application/x-www-form-urlencoded'

    logData = ->
      request.post(url).set('Content-Type',mime).send(newData).end (res) =>
        if res.text.startsWith("Error:") or res.status isnt 200
          #if @logsPending is 0 then emit(Events.logsFlushed)
          callback?(new Error(res.text), null)
        else
          #if @logsPendings is 0 then emit(Events.logsFlushed)
          callback?(null, res.text)
    
    if @logExists
      logData()
    else
      @create -> logData() 


  @createLogger: (params={}) ->
    baseUrl = "http://#{params.host}:#{params.port}"
    new LogMeUp(baseUrl, params.collection, params.app)

  @loadDefault: ->
    if defaultLogger? then return defaultLogger

    configFiles = ['logmeup.json']
    dirs = ['./', './config/']
    paths = []

    for dir in dirs
      for file in configFiles
        paths.push(path.join(process.cwd(),dir,file))
        paths.push(path.join(__dirname,file))

    for p in paths
      #console.log p
      if path.existsSync(p)
        config = JSON.parse(fs.readFileSync(p))
        defaultLogger = LogMeUp.createLogger(config)
    defaultLogger

LogMeUp.loadDefault()

exports.LogMeUp = LogMeUp
exports.default = defaultLogger