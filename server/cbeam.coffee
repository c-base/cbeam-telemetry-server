mqtt = require 'mqtt'

exports.connect = (config, callback) ->
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

exports.filterMessages = (topic, msg, dictionaries, callback) ->
  value = msg.toString()
  handlers = []
  for dictionary in dictionaries
    for key, val of dictionary.measurements
      continue unless val.options.topic is topic
      handlers.push val
  unless handlers.length
    return callback [] unless unhandled.indexOf(topic) is -1
    unhandled.push topic
    console.log "Unhandled key #{topic}: #{JSON.stringify(value)}"
    return callback []
  callback handlers.map (handler) ->
    return message =
      id: handler.key
      value: handler.callback value
      timestamp: Date.now()

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
