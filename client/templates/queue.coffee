Template.queue.helpers
  storeQueue: () ->
    array = []
    for i in [1..12]
      array.push {
        _id:0
        displayFakeName : "(XXX)XXX-2288"
        partyOf: 3
        waitTime: '2:34'

      }
    return array
    # ...

Template.queue.events
  'click .openLogin': (e,t) ->
    addMeInData = {
      
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
          Meteor.call 'addMeInByEmail', storeId, email, partyOfNumber, (e,r)->
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