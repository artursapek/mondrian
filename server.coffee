connect = require('connect')
http = require('http')

directory = [__dirname, "build"].join('/')

connect()
  .use(connect.static(directory))
  .use(connect.logger('dev'))
  .listen 3000

console.log 'Listening on port 3000.'
