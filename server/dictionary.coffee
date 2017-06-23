class Dictionary
  constructor: (@name, @key) ->
    @measurements = {}

  addMeasurement: (name, key, values, callback) ->
    unless callback
      callback = (val) -> val

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
