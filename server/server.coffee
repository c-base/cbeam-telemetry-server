cbeam = require './cbeam'
history = require './history'
express = require 'express'
cors = require 'cors'
http = require 'http'
ws = require 'websocket'

class Server
  listeners: []
  points: []
  chunkSaver: null
  constructor: (@config) ->
    @config.theme = 'Espresso' unless @config.theme
    @config.timeWindow = 24 * 60 * 60 * 1000 unless @config.timeWindow
    unless @config.persistence
      @config.persistence = 'openmct.plugins.LocalStorage()'
    unless @config.openmctRoot
      @config.openmctRoot = process.env.OPENMCT_ROOT or 'node_modules/openmct/dist'
    @history = new history @config
    @app = express()

    @app.use express.static 'assets'
    @app.use "/#{@config.openmctRoot}", express.static @config.openmctRoot
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
    @app.get '/telemetry/latest/:pointId', cors(), (req, res) =>
      unless @history.getMeasurement req.params.pointId
        res.status(404).end()
        return
      if req.query.timestamp
        res.json cbeam.latestState req.params.pointId
        return
      state = cbeam.latestState req.params.pointId
      if typeof state?.value isnt 'undefined'
        res.json state.value
        return
      res.json null
    @app.get '/telemetry/:pointId', cors(), (req, res) =>
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
    @wssServer = http.createServer (req, res) ->
      res.writeHead 404
      res.end()
    @wssServer.listen @config.wss_port, (err) =>
      @wss = new ws.server
        httpServer: @wssServer
        autoAcceptConnections: false
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
            savePoints = @points.slice 0
            @history.recordBatch savePoints, (err) ->
              if err
                console.log err
                # Save failed, put the failed data points back to the list
                @points = savePoints.concat @points
            @points = []
            @chunkSaver = null
          , 10000
    @wss.on 'request', (request) =>
      socket = request.accept null, request.origin
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
      socket.sendUTF JSON.stringify msg

  # Listen for requests
  socket.on 'message', (message) ->
    parts = message.utf8Data.split ' '
    handler = handlers[parts[0]]
    unless handler
      console.log "No handler for #{parts[0]}"
      return
    handler.apply handlers, parts.slice 1

  # Remove subscription when connection closes
  socket.on 'close', ->
    server.listeners = server.listeners.filter (l) ->
      l isnt notify
  socket.on 'error', ->
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
