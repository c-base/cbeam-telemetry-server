config = require './config'
cbeam = require './cbeam'
ws = require 'ws'

exports.initialize = (callback) ->
  server =
    wss: new ws.Server
      port: config.port
    histories: {}
    listeners: []
    dictionary: require config.dictionary

  cbeam.connect (err, client) ->
    return callback err if err
    server.cbeam = client
    callback null, server

exports.handleConnection = (server, socket) ->
  # Topics subscribed by this connection
  subscriptions = {}

  handlers =
    dictionary: ->
      socket.send JSON.stringify
        type: 'dictionary'
        value: server.dictionary
    subscribe: (id) ->
      console.log "SUB: #{id}"
      subscriptions[id] = true
    unsubscribe: (id) ->
      console.log "UNSUB: #{id}"
      delete subscriptions[id]
    history: (id) ->
      console.log "HIST: #{id}", server.histories[id]
      socket.send JSON.stringify
        type: 'history'
        id: id
        value: server.histories[id]

  notify = ->
    for id, value of subscriptions
      console.log "NOTIFY", id
      history = server.histories[id]
      continue unless history
      console.log history.length
      socket.send JSON.stringify
        type: 'data'
        id: id
        value: history[history.length - 1]

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

main = ->
  exports.initialize (err, server) ->
    if err
      console.error err
      process.exit 1
    console.log "c-beam telemetry provider running on port #{config.port}"

    # Subscribe to all messages
    server.cbeam.subscribe '#'
    server.cbeam.on 'message', (topic, msg) ->
      messages = cbeam.filterMessages topic, msg, server.dictionary
      return unless messages.length
      for msg in messages
        server.histories[msg.id] = [] unless server.histories[msg.id]
        server.histories[msg.id].push
          timestamp: Date.now()
          value: msg.value
        console.log server.histories
      server.listeners.forEach (listener) ->
        do listener
    server.wss.on 'connection', (socket) ->
      exports.handleConnection server, socket

main() unless module.parent
