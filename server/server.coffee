cbeam = require './cbeam'
history = require './history'
express = require 'express'
ws = require 'ws'

class Server
  listeners: []
  points: []
  chunkSaver: null
  constructor: (@config) ->
    @config.theme = 'Espresso' unless @config.theme
    @config.timeWindow = 24 * 60 * 60 * 1000 unless @config.timeWindow
    unless @config.persistence
      @config.persistence = 'openmct.plugins.LocalStorage()'
    @history = new history @config
    @app = express()

    @app.use express.static 'assets'
    @app.use '/node_modules/openmct', express.static 'node_modules/openmct'
    @app.set 'view engine', 'ejs'
    @app.get '/', (req, res) =>
      res.render 'index', @config
    @app.get '/index.html', (req, res) =>
      res.render 'index', @config
    @app.get '/dictionary/:dict.json', (req, res) =>
      for dict in @config.dictionaries
        if dict.key is req.params.dict
          res.json dict.toJSON()
          return
      res.status(404).end()
    @app.get '/telemetry/:pointId', (req, res) =>
      start = parseInt req.query.start
      end = parseInt req.query.end
      ids = req.params.pointId.split ','
      @history.query ids[0], start, end, (err, response) ->
        if err
          console.log err
          res.status(500).end()
          return
        res.json response
      return

  start: (callback) ->
    @wss = new ws.Server
      port: @config.wss_port
    @app.listen @config.port, (err) =>
      return callback err if err
      cbeam.connect @config, (err, client) =>
        return callback err if err
        @history.connect (err) =>
          return callback err if err
          @cbeam = client
          do @subscribe
          cbeam.announce @cbeam, @config.dictionaries, callback
          setInterval =>
            cbeam.announce @cbeam, @config.dictionaries, ->
          , 30000

  subscribe: ->
    # Subscribe to all messages
    @cbeam.subscribe '#'
    @cbeam.on 'message', (topic, msg) =>
      cbeam.filterMessages topic, msg, @config.dictionaries, (points) =>
        return unless points.length
        for point in points
          @points.push point
          @listeners.forEach (listener) ->
            listener point
        unless @chunkSaver
          @chunkSaver = setTimeout =>
            @history.recordBatch @points.slice(0), (err) ->
              if err
                console.log err
                process.exit 1
            @points = []
            @chunkSaver = null
          , 5000
    @wss.on 'connection', (socket) =>
      exports.handleConnection @, socket

exports.handleConnection = (server, socket) ->
  # Topics subscribed by this connection
  subscriptions = {}

  handlers =
    subscribe: (id) ->
      subscriptions[id] = true
    unsubscribe: (id) ->
      delete subscriptions[id]

  notify = (msg) ->
    for id, value of subscriptions
      continue unless msg.id is id
      socket.send JSON.stringify msg

  # Listen for requests
  socket.on 'message', (message) ->
    parts = message.split ' '
    handler = handlers[parts[0]]
    unless handler
      console.log "No handler for #{parts[0]}"
      return
    handler.apply handlers, parts.slice 1

  # Remove subscription when connection closes
  socket.on 'close', ->
    server.listeners = server.listeners.filter (l) ->
      l isnt notify

  # Register listener
  server.listeners.push notify

main = (config) ->
  exports.initialize config, (err, server) ->
    if err
      console.error err
      process.exit 1
    console.log "c-beam telemetry server running on port #{config.port}"
    console.log "c-beam telemetry provider running on port #{config.wss_port}"
    console.log "Open c-beam telemetry server at http://#{config.host}:#{config.port}"


module.exports = Server
