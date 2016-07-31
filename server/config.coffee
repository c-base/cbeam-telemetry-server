module.exports =
  port: process.env.PORT or 8081
  broker: process.env.MQTT_BROKER or 'mqtt://10.0.1.17'
  dictionary: './dictionary.json'
