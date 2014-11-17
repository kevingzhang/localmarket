Template.adminaction.helpers
  positionCount: () ->
    99
    # ...
  estimateWaitingTime:()->
    "16 minutes"

Template.adminaction.events
  'click .pre-order-btn': (e,t) ->
    Session.set 'canBack', true
    Router.go 'recipes'
    # ...
  'click .kickout-me-btn':(e,t)->
    myQid = t.data.qid
    
    Meteor.call 'kickOff', myQid, t.data.storeInfo._id, (e,r)->
      if e?
        console.log "ERROR:", e.message
      
      Session.set 'canBack', false
      # nextInitiator = 'back'
      # history.back()
      #Router.go 'queue', {storeId:t.data.storeInfo._id}