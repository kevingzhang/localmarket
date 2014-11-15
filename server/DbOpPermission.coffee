queueColl.deny
  insert: (userId, doc) ->
    return false
    # ...
  update: (userId, doc, fields, modifier) ->
    unless userId?
      return true 
    storeId = doc.storeId
    storeDoc = storeColl.findOne storeId
    if storeDoc.access.waiter.indexOf(userId) is -1
      return true
    return false
    # ...
  remove: (userId, doc) ->
    unless userId?
      return true 
    storeId = doc.storeId
    storeDoc = storeColl.findOne storeId
    if storeDoc.access.waiter.indexOf(userId) is -1
      return true
    return false
    # ...
 
    # ...
queueColl.allow
  insert: (userId, doc) ->
    return true
    # ...
  update: (userId, doc, fields, modifier) ->
    return true
    # ...
  remove: (userId, doc) ->
    return false
    # ...
  
  
    # ...
  