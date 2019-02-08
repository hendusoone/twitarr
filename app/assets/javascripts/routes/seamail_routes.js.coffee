Twitarr.SeamailLoadingRoute = Twitarr.LoadingRoute.extend()

Twitarr.SeamailIndexRoute = Ember.Route.extend
  model: ->
    Twitarr.SeamailMeta.list().fail((response)=>
      if response.status? && response.status == 401
        alert('You must be logged in to view seamail.')
        @transitionTo('index')
        return
      else
        alert('Something went wrong. Please try again later.')
      window.history.back()
      return
    )

  actions:
    reload: ->
      @refresh()

Twitarr.SeamailDetailRoute = Ember.Route.extend
  model: (params) ->
    Twitarr.Seamail.get(params.id).fail((response)=>
      if response.responseJSON?.error?
        alert(response.responseJSON.error)
      else if response.status? && response.status == 401
        alert('You must be logged in to view seamail.')
        @transitionTo('index')
        return
      else
        alert('Something went wrong. Please try again later.')
      window.history.back()
      return
    )

  actions:
    reload: ->
      @refresh()
