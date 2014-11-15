Meteor.methods
  createActivity: (activity, tweet, loc) ->
    check(Meteor.userId(), String);
    check(activity, {
      recipeName: String,
      text: String,
      image: String
    });
    check(tweet, Boolean);
    check(loc, Match.OneOf(Object, null));
    
    activity.userId = Meteor.userId()
    activity.userAvatar = Meteor.user().services.twitter.profile_image_url_https
    activity.userName = Meteor.user().profile.name
    activity.date = new Date
    
    if (not this.isSimulation and loc)
      activity.place = getLocationPlace(loc)
    
    id = Activities.insert(activity)
    
    if (not this.isSimulation and tweet)
      tweetActivity(activity);
    
    return id;




################################################################

  addMeInByPhoneNumber:(storeId, phoneNumber, email, partyOfNumber)->
    customerDoc = customerColl.findOne {phoneNumbers: phoneNumber}
    unless customerDoc?
      customerId = Meteor.call 'newCustomer', {phoneNumber:phoneNumber, email:email}
      customerDoc = customerColl.findOne customerId
    unless customerDoc?
      console.log 'ERROR: add new customer failed. By phone Number', phoneNumber 
      throw new Meteor.Error 'ERROR: add new customer failed. By phone Number'
    addInTime = new Date()
    displayFakeName = phoneNumber.slice(0,3) + '-XXX-XX' + phoneNumber.slice(phoneNumber.length - 2)
    queueId = queueColl.insert storeId:storeId, usePhoneNumber:phoneNumber, displayFakeName: displayFakeName, customer:customerDoc, partyOf:partyOfNumber, inTime:addInTime, status:'waiting'
    customerColl.update {_id:customerId}, $push:{inQueue:queueId}
    return {displayFakeName: displayFakeName, qId:queueId}

  addMeInByEmail:(storeId, email, partyOfNumber)->
    customerDoc = customerColl.findOne {emails: email}
    unless customerDoc?
      customerId = Meteor.call 'newCustomer', {email:email}
      customerDoc = customerColl.findOne customerId
    unless customerDoc?
      console.log 'ERROR: add new customer failed. By email', email 
      throw new Meteor.Error 'ERROR: add new customer failed. By phone Number'
    addInTime = new Date()
    atSignIndex = email.indexOf('@')
    displayFakeName = email.slice(0,3) + 'XXX@' + email.slice(atSignIndex, 3) + 'XXX' + email.slice(email.length - 4)
    queueId = queueColl.insert storeId:storeId, useEmail:email, displayFakeName:displayFakeName, customer:customerDoc, partyOf:partyOfNumber, inTime:addInTime, status:'waiting'
    customerColl.update {_id:customerId}, $push:{inQueue:queueId}
    return {displayFakeName: displayFakeName, qId:queueId}


  'addNewStore' : (storeName, property)->
    newDoc = counterColl.findAndModify 
      query:{_id:'store'}
      update:{$inc:{curId:1}}
      new: true
      upsert: true
    unless newDoc?
      console.log "counterColl.findAndModify returns nothing"
      throw new Meteor.Error "counterColl.findAndModify returns nothing"
      
    newStoreId =  newDoc.curId
    return storeColl.insert 
      _id:"#{newStoreId}"
      name:storeName
      property:property



  'cancelMe':(qId, storeId, phoneNumber, email)->
    console.log "cancelMe #{qId}, #{storeId}, #{phoneNumber}, #{email}"
    queueObj = queueColl.findOne qId
    unless queueObj then throw new Meteor.Error ('Cannot find in queue')
    

    if (queueObj.storeId is storeId) and ((queueObj.usePhoneNumber is phoneNumber ) or (queueObj.userEmail is email))
      notifyObj = {}
      
      notifyObj.name = 'User Cancelled'
      notifyObj.autoCleanup = 30

      queueColl.update {_id:qId}, {$set:{status:'userCancelled'}, $push:{notifications:notifyObj}}
      if notifyObj.autoCleanup >0
        Meteor.setTimeout ()->
          console.log "timeout to remove notify #{qId}, #{notifyObj.name}"
          queueColl.update {_id:qId}, {$pull:{notifications:{name:notifyObj.name}}}
        , notifyObj.autoCleanup * 1000
        return 'done'
    else
      throw new Meteor.Error ('Cannot ID this user is working on his own queue')



  dbInit:()->
    counterColl.insert {_id:'store', curId:0}
    counterColl.insert {_id:'customer', curId:0}

  getAccessStoreByUserId : ()->
    userId = Meteor.userId()
    console.log userId
    if userId?
      #stores = storeColl.find {$or:['access.admin':{$elemMatch:userId}, 'access.keeper':{$elemMatch:userId}, 'access.waiter':{$elemMatch:userId}, 'access.staff':{$elemMatch: userId}]}
      stores = storeColl.find {$or:[{'access.admin':userId}, {'access.keeper':userId}, {'access.waiter':userId}, {'access.staff':userId}]}
      

      console.log "store Number:", stores.count()
      ret = []
      stores.forEach (s)->
        storeObj = {_id:s._id, storeName:s.name, storeAddress:s.property?.address}
        if s.access.staff.indexOf(userId) isnt -1
          storeObj.role = 'staff'
        if s.access.waiter.indexOf(userId) isnt -1
          storeObj.role = 'waiter'
        if s.access.keeper.indexOf(userId) isnt -1
          storeObj.role = 'keeper'
        if s.access.admin.indexOf(userId) isnt -1
          storeObj.role = 'admin'
        ret.push storeObj 
      return ret 
    else
      return null


  'getMyPositionQueueId' : (storeId, phoneNumber, email)->
    console.log "#{storeId}, #{phoneNumber}, #{email}"
    queueObj = queueColl.findOne {storeId: storeId, status:{$exists:true}, $or:[{usePhoneNumber: phoneNumber},{useEmail:email}]}
    return queueObj?._id

  newCustomer:(options)->
    
    #user add using his phone phoneNumber
    newCustomerDoc = {}
    if options.phoneNumber?
      newCustomerDoc.phoneNumbers = [options.phoneNumber]
    if options.email?
      newCustomerDoc.emails = [options.email]
    if Object.getOwnPropertyNames(newCustomerDoc).length is 0
      console.log "ERROR: new customer should either has phone number or email address"
      return 
    customerId = customerColl.insert newCustomerDoc
    return customerId


  "sendSmsToUser":(phoneNumber)->
    ACCOUNT_SID = process.env.TWILIO_ACCOUNT_SID 
    AUTH_TOKEN = process.env.TWILIO_AUTH_TOKEN

    console.log "#{ACCOUNT_SID}, #{AUTH_TOKEN}"
    return 
    twilio = Twilio ACCOUNT_SID, AUTH_TOKEN
    options = {
      to:phoneNumber, #// Any number Twilio can deliver to
      from: '+14084007678', #// A number you bought from Twilio and can use for outbound communication
      body: 'word to your mother.' #// body of the SMS message
    }
    console.log "going to send sms"
    twilio.sendSms options, (err, responseData) ->
      # //this function is executed when a response is received from Twilio
      console.log "#{JSON.stringify err}, #{JSON.stringify responseData}"
      unless err  #// "err" is an error received during the request, if any
        #// "responseData" is a JavaScript object containing data received from Twilio.
        
        #// A sample response from sending an SMS message is here (click "JSON" to see how the data appears in JavaScript):
        
        #// http://www.twilio.com/docs/api/rest/sending-sms#example-1
        console.log(responseData.from); #// outputs "+14506667788"
        console.log(responseData.body); #// outputs "word to your mother."
      

  addUserAccessToStore: (userId, storeId, right)->
    if Meteor.user()?.emails[0]?.address isnt 'asdf@asdf.com'
      throw new Meteor.Error 'Only Admin can access addUserAccessToStore function'
    switch right
      when 'staff'
        storeColl.update _id:storeId,{ $addToSet:{'access.staff': userId}}
      when 'waiter'
        storeColl.update _id:storeId, {$addToSet:{'access.waiter':userId, 'access.staff':userId}}
      when 'keeper'
        storeColl.update _id:storeId, {$addToSet:{'access.keeper':userId, 'access.waiter':userId, 'access.staff': userId}}
      when 'admin'
        storeColl.update _id:storeId, {$addToSet:{'access.admin': userId, 'access.keeper':userId, 'access.waiter':userId, 'access.staff': userId}}
      else
        throw new Meteor.Error "addUserAccessToStore: New right not handled: #{right}"

  removeUserAccessToStore : (userId, storeId, right)->
    if Meteor.user()?.emails[0]?.address isnt 'asdf@asdf.com'
      throw new Meteor.Error 'Only Admin can access removeUserAccessToStore function'
    switch right
      when 'staff'
        storeColl.update _id:storeId, {$pull:{'access.staff': userId}}
      when 'waiter'
        storeColl.update _id:storeId, {$pull:{'access.waiter':userId, 'access.staff': userId}}
      when 'keeper'
        storeColl.update _id:storeId, {$pull:{'access.keeper':userId, 'access.waiter':userId, 'access.staff': userId}}
      when 'admin'
        storeColl.update _id:storeId, {$pull:{'access.admin': userId, 'access.keeper':userId, 'access.waiter':userId, 'access.staff': userId}}
      else
        throw new Meteor.Error "removeUserAccessToStore: New right not handled: #{right}"

  addUserAccessToStoreByEmail: (email, storeId, right)->
    console.log "addUserAccessToStoreByEmail: (#{email}, #{storeId}, #{right})"
    users = Meteor.users.find {emails:{$elemMatch:{address: email}}}
    if users.count() > 1
      throw new Meteor.Error "More than one user has same email address #{email}. User merge is needed. Not done yet"
    if users.count() is 1
      user = users.fetch()[0]
      return Meteor.call 'addUserAccessToStore', user._id, storeId, right
    else
      throw new Meteor.Error "Cannot find user by email #{email}"

  removeUserAccessToStoreByEmail: (email, storeId, right)->
    users = Meteor.users.find {emails:{$elemMatch:{address: email}}}
    if users.count() > 1
      throw new Meteor.Error "More than one user has same email address #{email}. User merge is needed. Not done yet"
    if users.count() is 1
      user = users.fetch()[0]
      return Meteor.call 'removeUserAccessToStore', user._id, storeId, right
    else
      throw new Meteor.Error "Cannot find user by email #{email}"

  getHighestAccessRightToStore:(userId, storeId)->
    storeObj = storeColl.findOne _id:storeId
    unless storeObj?.access? then return ''
    if storeObj.access.admin?.indexOf(userId) > -1 then return 'admin'
    if storeObj.access.keeper?.indexOf(userId) > -1 then return 'keeper'
    if storeObj.access.waiter?.indexOf(userId) > -1 then return 'waiter'
    if storeObj.access.staff?.indexOf(userId) > -1 then return 'staff'
    return ''

  "AddFakeUser": (storeId, count)->
    #@unblock()
    CreateFakeUser = ()->
      phoneNumber = (Math.random() * 100000000000000).toString().slice(0,10)
      emailDomain = Fake.fromArray(['@gmail.com', '@hotmail.com', '@icloud.com', '@yahoo.com', '@something.com'])
      email = Fake.word() + emailDomain
      partyOf = Fake.fromArray([2,1,5,3,6,8,7,4])
      console.log "going to add new fake user #{phoneNumber}, #{email}, #{partyOf}"
      Meteor.call 'addMeInByPhoneNumber', storeId, phoneNumber, email, partyOf 
      count -= 1
      if count >0
        console.log "count is #{count }"
        Meteor.setTimeout CreateFakeUser, Math.round(Math.random()*10000)
        return ''
    
    Meteor.setTimeout CreateFakeUser ,Math.round(Math.random()*10000)
    return ''






