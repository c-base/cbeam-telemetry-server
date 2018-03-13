mqtt = require 'mqtt'

booleanStates = {}

exports.latestState = (id) ->
  if typeof booleanStates[id] is 'undefined'
    return null
  booleanStates[id]

exports.connect = (config, callback) ->
  booleanStates = {}
  client = mqtt.connect config.broker
  client.on 'connect', ->
    return unless callback
    callback null, client
    callback = null
  client.on 'error', (err) ->
    return unless callback
    callback err
    callback = null

unhandled = []

exports.announce = (client, dictionaries, callback) ->
  for dictionary in dictionaries
    continue unless dictionary.options.announce
    def =
      protocol: 'discovery'
      command: 'participant'
      payload:
        id: "openmct-#{dictionary.key}"
        component: "openmct/#{dictionary.key}"
        icon: dictionary.options.icon
        label: "OpenMCT logger for #{dictionary.name}"
        role: dictionary.key
        inports: []
        outports: []
    for key, val of dictionary.measurements
      def.payload.inports.push
        id: val.name
        type: val.values[0].format
        hidden: val.options.hidden
        queue: val.options.topic
    client.publish 'fbp', JSON.stringify def
  do callback

exports.filterMessages = (topic, msg, dictionaries, callback) ->
  try
    value = JSON.parse msg.toString()
  catch e
    value = msg.toString()
  handlers = []
  for dictionary in dictionaries
    for key, val of dictionary.measurements
      continue unless val.options.topic is topic
      handlers.push val
  unless handlers.length
    return callback [] unless unhandled.indexOf(topic) is -1
    unhandled.push topic
    console.log "Unhandled key #{topic}"
    return callback []
  points = handlers.map (handler) ->
    return message =
      id: handler.key
      value: handler.callback value
      timestamp: Date.now()
  seenBooleans = points.filter((point) ->
    # We're only interested in boolean values
    return false unless typeof point.value is 'boolean'
    # We're only interested in booleans we have a previous state for
    if typeof booleanStates[point.id] is 'undefined'
      booleanStates[point.id] =
        value: point.value
        timestamp: point.timestamp
      return false
    # We're only interested in booleans that change state
    return false if booleanStates[point.id].value is point.value
    true
  ).map (point) ->
    prevState = booleanStates[point.id].value
    booleanStates[point.id] =
      value: point.value
      timestamp: point.timestamp
    return prevPoint =
      id: point.id
      value: prevState
      timestamp: point.timestamp - 1

  callback seenBooleans.concat points

main = ->
  exports.connect (err, client) ->
    if err
      console.error err
      process.exit 1
    client.subscribe '#'
    client.on 'message', (topic, msg) ->
      message = msg.toString()
      console.log "#{topic}: #{message}"

main() unless module.parent
