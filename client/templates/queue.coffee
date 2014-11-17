Template.queue.created = ->
  @isStaffOrHigher = new ReactiveVar()
  Session.set('myPositionQueueId', undefined)

Template.queue.rendered = ()->
  unless (Session.get 'myPositionQueueId')?
    console.log "in rendered, data is ", @data
    unless @data.storeInfo? then return
    Meteor.call 'getMyPositionQueueId', @data.storeInfo._id, App.Util.getCookie('phoneNumber'), App.Util.getCookie('email'), (e,r)->
      if e?
        console.log 'getMyPositionQueueId ERROR:', e.message
      else
        Session.set 'myPositionQueueId', r

  unless @isStaffOrHigher.get()?
    t = @
    Meteor.call 'doesUserHasRightOfStore', @data.storeInfo._id, 'staff', (e,r)->
      console.log "doesUserHasRightOfStore", r 
      t.isStaffOrHigher.set(r)



Template.queue.helpers
  storeQueue: () ->
    queueColl.find storeId:@storeInfo._id

  waitTime:()->
    nowTime = Session.get('nowTime')
    moment.duration(nowTime - @inTime).humanize()

  isntInQueue:()->
    Session.get('myPositionQueueId') isnt true


Template.queue.events
  'click .openLogin': (e,t) ->
    addMeInData = {
      cookiePhoneNumber:()->
        App.Util.getCookie 'phoneNumber'
      cookieEmail:()->
        App.Util.getCookie 'email'
      onOk:(phoneNumber, email, partyOfNumber)->
        if !!phoneNumber
          unless App.Util.validatePhoneNumber(phoneNumber)
            alert "Phone number is not valid, try again please"
            return 
          phoneNumber = phoneNumber.replace(/(\d{3})(\d{3})(\d{4})/, '$1-$2-$3')
          
          storeId = t.data.storeInfo._id
          Meteor.call 'addMeInByPhoneNumber', storeId, phoneNumber, email, partyOfNumber, (e,r)->
            if e?
              console.log 'ERROR: Meteor.call addMeInByPhoneNumber :' , e.message
              return 
            App.Util.setCookie 'phoneNumber', phoneNumber
            if !!email
              App.Util.setCookie 'email', email
            Session.set 'myPositionQueueId', r.qId
            alert "You are added! Your name will display as #{r.displayFakeName}"

          # ...
        else if !!email
          Meteor.call 'addMeInBuyEmail', storeId, email, partyOfNumber, (e,r)->
            if e?
              console.log 'ERROR: Meteor.call addMeInByEmail :' , e.message
              return 
            App.Util.setCookie 'email', email
            Session.set 'myPositionQueueId', r.qId
            bootbox.alert "You are added! Your name will display as #{r.displayFakeName}"
        else
          alert "Please input either phone number or email"

    }
    Overlay.open('addMeIn', addMeInData);
    # ...
  'click .my-position':(e,t)->
    Session.set 'canBack', true
    Router.go 'action',{storeId:t.data.storeInfo._id}

  'click .queue-in-list':(e,t)->
    if t.isStaffOrHigher?.get()
      qid = e.currentTarget.getAttribute 'data-qid'
      return unless qid?
      Session.set 'canBack', true
      Router.go 'adminaction',{storeId:t.data.storeInfo._id, qid:qid}




