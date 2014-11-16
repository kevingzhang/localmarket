Template.action.helpers
  positionCount: () ->
    99
    # ...
  estimateWaitingTime:()->
    "16 minutes"

Template.action.events
  'click .pre-order-btn': (e,t) ->
    Session.set 'canBack', true
    Router.go 'recipes'
    # ...
  'click .cancel-me-btn':(e,t)->
    myQid = Session.get 'myPositionQueueId'
    unless myQid?
      console.log "ERROR:You are not in the queue"
    Meteor.call 'cancelMe', myQid, t.data.storeInfo._id, App.Util.getCookie('phoneNumber'), App.Util.getCookie('email'), (e,r)->
      if e?
        console.log "ERROR:", e.message
      else
        Session.set 'myPositionQueueId', undefined
      Session.set 'canBack', false
      # nextInitiator = 'back'
      # history.back()
      #Router.go 'queue', {storeId:t.data.storeInfo._id}