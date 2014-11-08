Activities.allow
  insert: (userId, doc) ->
    return doc.userId is userId
