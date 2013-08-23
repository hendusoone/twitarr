Twitarr.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'announcements'

Twitarr.PostsChildRoute = Ember.Route.extend
  model: (params) ->
    params
  setupController: (controller) ->
    controller.reload()

Twitarr.AdminRoute = Ember.Route.extend
  model: ->
    Twitarr.User.list()

Twitarr.PostsPopularRoute = Twitarr.PostsChildRoute.extend()
Twitarr.PostsMineRoute = Twitarr.PostsChildRoute.extend()
Twitarr.PostsSearchRoute = Twitarr.PostsChildRoute.extend
  setupController: (controller, params) ->
    if typeof params is 'string'
      controller.set 'tag', params
    else
      controller.set 'tag', params.tag
    @_super(controller, params)
Twitarr.PostsUserRoute = Twitarr.PostsChildRoute.extend
  redirect: (params) ->
    @transitionTo 'posts.mine' if @controllerFor('application').get('login_user') is @get_user(params)
  setupController: (controller, params) ->
    controller.set 'user', @get_user(params)
    @_super(controller, params)
  get_user: (params) ->
    if typeof params is 'string'
      params
    else
      params.user

Twitarr.AnnouncementsRoute = Ember.Route.extend
  model: ->
    Twitarr.Message.list('announcements')
