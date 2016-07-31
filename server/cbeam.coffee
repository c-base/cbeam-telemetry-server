config = require './config'
mqtt = require 'mqtt'

exports.connect = (callback) ->
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

  # Handle JSON messages
  if message.indexOf '{' isnt -1
    try
      message = JSON.parse message
    catch e
      msgs.push
        id: identifier
        value: message
      return msgs

    for key, value of message
      msgs.push
        id: "#{identifier}.#{key}"
        value: value
    return msgs

  msgs.push
    id: identifier
    value: message
  return msgs

exports.findExposedKeys = (dictionary) ->
  keys = []
  for system in dictionary.subsystems
    continue unless system.measurements?.length
    for measurement in system.measurements
      keys.push measurement.identifier
  return keys
unhandled = [] 
exports.filterMessages = (topic, msg, dictionary) ->
  msgs = exports.normalizeMessage topic, msg
  return [] unless msgs.length
  keys = exports.findExposedKeys dictionary
  #console.log keys, msgs.map (msg) -> msg.id
  msgs.filter (msg) ->
    return true if keys.indexOf(msg.id) isnt -1
    return false if unhandled.indexOf(msg.id) isnt -1
    unhandled.push msg.id
    console.log "Unhandled key #{msg.id}: #{msg.value}"
    false

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
