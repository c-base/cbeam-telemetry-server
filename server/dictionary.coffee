class Dictionary
  constructor: (@name, @key, @options) ->
    @measurements = {}
    @options = {} unless @options
    unless typeof @options.announce is 'boolean'
      @options.announce = true
    unless @options.icon
      @options.icon = 'line-chart'
    unless @options.description
      @options.description = @name

  addMeasurement: (name, key, values, options, callback) ->
    if typeof options is 'function'
      callback = options
    unless options
      options = {}
    unless typeof options.persist is 'boolean'
      options.persist = true
    unless typeof options.hidden is 'boolean'
      options.hidden = false
    unless options.timeseries
      options.timeseries = key
    unless options.topic
      options.topic = key

    if values.length
      values[0].name = 'Value'
      values[0].key = 'value'
      values[0].hints =
        range: 1
      if values[0].format and not callback
        callback = @formatToCallback values[0].format
    unless callback
      callback = (val) -> val

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

  formatToCallback: (format) ->
    switch format
      when 'integer'
        return (val) -> parseInt val
      when 'float'
        return (val) -> parseFloat val
      when 'boolean'
        return (val) -> String(val) is 'true'
      else
        return (val) -> val

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
