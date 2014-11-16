Template.action.helpers
  positionCount: () ->
    99
    # ...
  estimateWaitingTime:()->
    "16 minutes"

Template.action.events
  'click .btn-primary': (e,t) ->
    Router.go 'recipes'
    # ...