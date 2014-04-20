require('derby').run ->
  port = process.env.PORT or 3331
  expressApp = require "./src/server/index.coffee"
  server = require('http').createServer expressApp
  server.listen port, (err)->
    if(err)
      console.log(err)
    else
      console.log('%d listening. Go to: http://localhost:%d/', process.pid, port)