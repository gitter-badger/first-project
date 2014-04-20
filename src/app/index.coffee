app = module.exports = require('derby').createApp('first-project', __filename)
app.loadViews __dirname + "/../../views/app"

app.component require "../../ui/first-component/index.coffee"
app.component require "../../ui/second-component/index.coffee"

app.get "/", (page, model) ->
  page.render("home")