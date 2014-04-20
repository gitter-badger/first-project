express = require "express"
derby = require "derby"
session = require "express-session"
app = require "../app/index.coffee"

racerBrowserChannel = require "racer-browserchannel"
liveDbMongo = require "livedb-mongo"
coffeeify = require "coffeeify"
redis = require "redis"
RedisStory = require("connect-redis")(session)

expressApp = module.exports = express();

if process.env.REDIS_HOST
  redisClient = redis.createClient process.env.REDIS_PORT, process.env.REDIS_HOST
  redisClient.auth process.env.REDIS_PASSWORD
else if process.env.OPENREDIS_URL
  redisUrl = require("url").parse process.env.OPENREDIS_URL
  redisClient = redis.createClient redisUrl.port, redisUrl.hostname
  redisClient.auth redisUrl.auth.split(":")[1]
else
  redisClient = redis.createClient()

mongoUrl = process.env.MONGO_URL or process.env.MONGOHQ_URL or "mongodb://localhost:27017/first-project"
derby.use require "racer-bundle"
store = derby.createStore
  db: liveDbMongo "#{mongoUrl}?auto_reconnect", safe: true
  redis: redis

store.on "bundle", (browserify) ->
  browserify.transform coffeeify

createUserId = (req, res, next) ->
  model = req.getModel()
  userId = req.session.userId ||= model.id()
  model.set '_session.userId', userId
  next()

expressApp
  .use require("static-favicon")()
  .use require("compression")()
  .use app.scripts store
  .use racerBrowserChannel store
  .use store.modelMiddleware()
  .use require("cookie-parser")()
  .use session
    secret: process.env.SESSION_SECRET or "YOUR SECRET HERE"
    store: new RedisStory()
  .use createUserId
  .use(app.router())

  .all "*", (req, res, next) ->
    next "404: #{req.url}"

