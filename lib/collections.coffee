@Activities = new Mongo.Collection 'activities'
Activities.latest = ->
  return Activities.find({}, {sort: {date: -1}, limit: 1});
