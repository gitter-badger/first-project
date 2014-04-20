app = module.exports = require('derby').createApp('first-project', __filename)
app.loadViews __dirname + "/../../views/app"

app.component require "../../ui/first-component/index.coffee"
app.component require "../../ui/second-component/index.coffee"

app.get "/", (page, model) ->
  page.render("home")

app.get "/users", (page, model, params, next) ->
  usersQuery = model.query "users", {}
  usersQuery.subscribe (err) ->
    return next err if err
    usersQuery.ref "_page.users"
    page.render "users"
    
app.get "/users/:id", (page, model, params, next) ->
  if params.id is "new"
    model.set '_page.user.name', ''
    return page.render "edit"
  user = model.at "users." + params.id
  user.subscribe (err) ->
    return next err if err
    return next() unless user.get()
    model.ref "_page.user", user
    page.render "edit"

class EditForm
  done: ->
    model = @model
    unless model.get "user.id"
      model.root.add "users", model.get "user"
    app.history.push "/users"

app.component "edit:form", EditForm