module.exports =
  host: process.env.HOST or 'localhost'
  port: process.env.PORT or 8080
  wss_port: process.env.PORT or 8082
  broker: process.env.MSGFLO_BROKER or 'mqtt://localhost'
  dictionary: './dictionary.json'
