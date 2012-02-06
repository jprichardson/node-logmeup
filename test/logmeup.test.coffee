{LogMeUp} = require('../lib/logmeup')
require('string')
require('testutil')
request = require('superagent')
fs = require('fs')

config = 
  port: 7070
  host: 'yourlogmeupserver.com'
  autocreate: false
  collection: 'test'
  app: 'logger'

describe 'Logmeup', ->
  logger = null
  
  beforeEach (done) ->
    logger = LogMeUp.createLogger(config)
    logger.delete ->
      done()

  describe '- create()', ->
    it 'should create the log file on the server if it doesnt exist', (done) ->
      logger.create (err, text) ->
        T err is null
        done()

    it 'should return an error if the collection/app exists', (done) ->
      logger.create (err,text) ->
        T err is null
        logger.create (err,text) ->
          T err isnt null
          done()

  describe '- delete()', ->
    it 'should delete the log file on the server if it exists', (done) ->
      logger.create (err,text) ->
        T err is null
        logger.delete (err,text) ->
          T err is null
          done()
    
    it 'should return an error if the log file doesnt exist', (done) ->
      logger.delete (err,text) ->
        T err isnt null
        done()
  
  describe '- logExists', ->
    it 'should return true/false depending upon whether the :collection_:app has been created', (done) ->
      F logger.logExists
      logger.create (err,text) ->
        T logger.logExists
        logger.delete (err,text) ->
          F logger.logExists
          done()
    
    it 'should return true if a create failed because the log file exists', (done) ->
      F logger.logExists
      logger.create (err,text) ->
        T logger.logExists
        logger.logExists = false #reset it
        logger.create (err,text) ->
          T err isnt null #<-- notice there's an error
          T logger.logExists
          done()


  describe '- log()', ->
    it 'should log the JSON data to the server', (done) ->
      logger.create (err,text) ->
        T err is null
        logdata = name: 'JP Richardson', company: 'Gitpilot'
        logger.log logdata, (err,text) -> #this is not typically called with a callback
          T err is null
          url = "#{logger.baseUrl}/log/#{config.collection}/#{config.app}/data.json"
          request.get(url).end (res) ->
            data = res.body
            #console.log JSON.stringify(data)
            T data.records[0].data.name is logdata.name
            T data.records[0].data.company is logdata.company
            done()
    
    it 'should log the string data to the server', (done) ->
      logger.create (err,text) ->
        T err is null
        logdata = "Hello dude!"
        logger.log logdata, (err,text) -> #this is not typically called with a callback
          T err is null
          url = "#{logger.baseUrl}/log/#{config.collection}/#{config.app}/data.json"
          request.get(url).end (res) ->
            #console.log res.text
            data = res.body
            #console.log JSON.stringify(data)
            T data.records[0].data is logdata
            done()

    it 'should still log data to the server if the autocreate config param is set to true', (done) ->
      logger3 = LogMeUp.createLogger(autocreate: true, host: config.host, port: config.port, collection: config.collection, app: config.app)
      logger3.delete -> #be sure it's deleted
        F logger3.logExists
        logdata = "Hello dude!"
        logger3.log logdata, (err,text) -> #this is not typically called with a callback
          T logger3.logExists
          T err is null
          url = "#{logger.baseUrl}/log/#{config.collection}/#{config.app}/data.json"
          request.get(url).end (res) ->
            data = res.body
            T data.records[0].data is logdata
            done()

    it 'should not log data if autocreate is set to false and the log file doesnt exist', (done) ->
      logdata = "Hello dude!"
      logger.log logdata, (err,text) -> #this is not typically called with a callback
        T err isnt null
        url = "#{logger.baseUrl}/log/#{config.collection}/#{config.app}/data.json"
        request.get(url).end (res) ->
          T res.text.contains('Error')
          done()

  describe '+ createLogger', ->
    it 'should create an instance of LogMeUp with input parameters', (done) ->
      logger2 = LogMeUp.createLogger(host: 'myserver.com', port: 9999, collection: 'mycollection', app: 'apache')
      #console.log logger2.baseUrl
      T logger2.baseUrl is 'http://myserver.com:9999'
      T logger2.collection is 'mycollection'
      T logger2.app is 'apache'
      done()

  describe '+ loadDefault()', ->
    it 'should create a logger using the settings from logmeup.json', (done) ->
      #you would use the module logmeup.default()
      config = JSON.parse(fs.readFileSync('logmeup.json').toString())

      logger3 = LogMeUp.loadDefault()
      T logger3.baseUrl is "http://#{config.host}:#{config.port}"
      T logger3.collection is config.collection
      T logger3.app is config.app
      done()
