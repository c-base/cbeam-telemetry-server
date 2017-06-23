class Dictionary
  constructor: (@name, @key) ->
    @measurements = {}

  addMeasurement: (name, key, values, callback) ->
    unless callback
      callback = (val) -> val
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
