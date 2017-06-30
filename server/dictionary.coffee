class Dictionary
  constructor: (@name, @key) ->
    @measurements = {}

  addMeasurement: (name, key, values, options, callback) ->
    if typeof options is 'function'
      callback = options
    unless callback
      callback = (val) -> val
    unless options
      options = {}
    unless typeof options.persist is 'boolean'
      options.persist = true
    unless options.timeseries
      options.timeseries = key

    if values.length
      values[0].name = 'Value'
      values[0].key = 'value'
      values[0].hints =
        range: 1

    values.push
      key: 'utc'
      source: 'timestamp'
      name: 'Timestamp'
      format: 'utc'
      hints:
        domain: 1

    @measurements[key] =
      name: name
      key: key
      values: values
      callback: callback
      options: options

  toJSON: ->
    def =
      name: @name
      key: @key
      measurements: []
    for key, val of @measurements
      def.measurements.push
        name: val.name
        key: val.key
        values: val.values
    def

module.exports = Dictionary
