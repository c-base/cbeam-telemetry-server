influx = require 'influx'

class History
  constructor: (@config) ->

  connect: (callback) ->
    @client = new influx.InfluxDB
      host: @config.history.host
      database: @config.history.db
      schema: @prepareSchema()
    @client.getDatabaseNames()
    .then (names) =>
      unless names.includes @config.history.db
        @client.createDatabase @config.history.db
    .then ->
      do callback
    .catch (e) ->
      callback e

  prepareSchema: ->
    schema = []
    for dictionary in @config.dictionaries
      for k, val of dictionary.measurements
        table =
          measurement: k
          fields:
            value: @toInfluxType val.values[0].format
          tags: []
        schema.push table
    return schema

  toInfluxType: (format) ->
    switch format
      when 'integer'
        return influx.FieldType.INTEGER
      when 'float'
        return influx.FieldType.FLOAT
      when 'boolean'
        return influx.FieldType.BOOLEAN
      else
        return influx.FieldType.STRING

  record: (point, callback) ->
    unless @client
      return callback new Error 'Not connected to InfluxDB'
    @client.writePoints([
      measurement: @prepareId point.id
      timestamp: new Date point.timestamp
      fields:
        value: point.value
    ])
    .then ->
      do callback
    .catch (e) ->
      callback e

  prepareId: (id) ->
    id.replace /\./g, '_'

  query: (id, start, end, callback) ->
    unless @client
      return callback new Error 'Not connected to InfluxDB'
    startString = new Date(start).toISOString()
    endString = new Date(end).toISOString()
    query = "
      select value from #{@prepareId(id)}
      where time > '#{startString}' and time < '#{endString}'
      order by time desc;
    "
    @client.query(query)
    .then (result) ->
      points = result.map (r) ->
        return res =
          id: id
          value: r.value
          timestamp: new Date(r.time).getTime()
      callback null, points
    .catch (e) ->
      callback e

module.exports = History
