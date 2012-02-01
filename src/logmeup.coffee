request = require('superagent')
path = require('path')
fs = require('fs')
require('string')

exports = module.exports

defaultLogger = null

class Logmeup
  constructor: (@baseUrl, @collection, @app) ->

  create: (callback) ->
    url = "#{@baseUrl}/log/#{@collection}/#{@app}" 
    request.put(url).end (res) ->
      if res.text.startsWith("Error:") or res.status isnt 200
        callback(new Error(res.text), null)
      else
        callback(null, res.text)


  delete: (callback) ->
    url = "#{@baseUrl}/log/#{@collection}/#{@app}" 
    request.del(url).end (res) ->
      if res.text.startsWith("Error:") or res.status isnt 200
        callback(new Error(res.text), null)
      else
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

    request.post(url).set('Content-Type',mime).send(newData).end (res) ->
      if res.text.startsWith("Error:") or res.status isnt 200
        if callback? then callback(new Error(res.text), null); return;
      else
        if callback? then callback(null, res.text)

  @createLogger: (params={}) ->
    baseUrl = "http://#{params.host}:#{params.port}"
    new Logmeup(baseUrl, params.collection, params.app)

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
        defaultLogger = Logmeup.createLogger(config)
    defaultLogger

Logmeup.loadDefault()


exports.Logmeup = Logmeup
exports.default = defaultLogger