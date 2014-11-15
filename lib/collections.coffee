@Activities = new Mongo.Collection 'activities'
Activities.latest = ->
  return Activities.find({}, {sort: {date: -1}, limit: 1});



@storeColl = new Mongo.Collection 'store'
@counterColl = new Mongo.Collection 'counter'
@queueColl = new Mongo.Collection 'queue'
@customerColl = new Mongo.Collection 'customer'

