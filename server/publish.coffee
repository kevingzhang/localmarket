

Meteor.publish 'storeInfo', (storeId)->
  console.log "publish storeInfo ", storeId
  return storeColl.find _id:storeId



Meteor.publish 'storeQueue', (storeId)->
  if @userId?
    if (Meteor.call 'getHighestAccessRightToStore', @userId, storeId) isnt ''

      return queueColl.find 
        storeId:storeId
        status:{$exists:true, $ne:'userCancelled'}

  #regular user

  return queueColl.find {storeId:storeId, status:{$exists:true, $ne:'userCancelled'}}, {fields:{displayFakeName:1, inTime:1, partyOf:1, status:1, notifications:1, storeId:1}}
