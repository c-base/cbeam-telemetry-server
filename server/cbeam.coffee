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

exports.normalizeMessage = (topic, msg) ->
  identifier = topic.replace /\//g, '.'
  message = msg.toString()
  msgs = []
  msgs.push
    id: identifier
    value: message
  return msgs

unhandled = []

exports.getSubscribedKeys = (dictionaries) ->
  keys = []
  for dictionary in dictionaries
    for key, val of dictionary.measurements
      keys.push key
  keys
exports.getKeyHandler = (dictionaries, key) ->
  keys = []
  for dictionary in dictionaries
    for k, val of dictionary.measurements
      continue unless k is key
      return val.callback
  null

exports.filterMessages = (topic, msg, dictionaries) ->
  msgs = exports.normalizeMessage topic, msg
  return [] unless msgs.length
  keys = exports.getSubscribedKeys dictionaries
  handled = msgs.filter (msg) ->
    return true if keys.indexOf(msg.id) isnt -1
    return false if unhandled.indexOf(msg.id) isnt -1
    unhandled.push msg.id
    console.log "Unhandled key #{msg.id}: #{JSON.stringify(msg.value)}"
    false
  handled.map (msg) ->
    handler = exports.getKeyHandler dictionaries, msg.id
    return msg unless handler
    msg.value = handler msg.value
    msg

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
