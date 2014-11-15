/*
  db.gs_sessions.findAndModify({
    query: {session: "cccPGt7qNhohwy8yo"},
    update: { $set:{ last_accessed: new Date()} }
  });
*/
if(Meteor.isServer){
  Future = Npm.require('fibers/future');
  Meteor.Collection.prototype.findAndModify = function(args){
    if(!this._name)
      throw new Meteor.Error(405,"findAndModify: Must have collection name.");
    if(!args)
      throw new Meteor.Error(405,"findAndModify: Must have args.");
    if(!args.query)
      throw new Meteor.Error(405,"findAndModify: Must have query.");
    if(!args.update && !args.remove)
      throw new Meteor.Error(405,"findAndModify: Must have update or remove.");
    var colname = this._name;
    var q = {};
    q.query = args.query;
    if(args.sort === undefined) q.sort = {};
    if(args.update)
      q.update = args.update;
    if(args.remove)
      q.remove = args.remove;
    q.options = {};
    if(args.new !== undefined) q.options.new = args.new;
    if(args.remove !== undefined) q.options.remove = args.remove;

    var db = MongoInternals.defaultRemoteCollectionDriver().mongo.db;
    var fut = new Future();

    db.collection(colname).findAndModify(
      q.query,
      q.sort,
      q.update,
      q.options,
      function(err, result) {
        if(err)
          fut.return(undefined);
        else
          fut.return(result);
      }
    );
    return fut.wait();
  };
}
if(Meteor.isClient){
  Meteor.Collection.prototype.findAndModify = function(args){
    if(!this._name)
      throw new Meteor.Error(405,"findAndModify: Must have collection name.");
    if(!args)
      throw new Meteor.Error(405,"findAndModify: Must have args.");
    if(!args.query)
      throw new Meteor.Error(405,"findAndModify: Must have query.");
    if(!args.update && !args.remove)
      throw new Meteor.Error(405,"findAndModify: Must have update or remove.");
    var colname = this._name;
    var q = {};
    q.query = args.query;
    q.options = {};
    if(args.sort !== undefined)
      q.options.sort = args.sort;
    if(args.fields !== undefined)
      q.options.fields = args.fields;
    if(args.skip !== undefined)
      q.options.skip = args.skip;
    if(args.upsert !== undefined)
      q.upsert = args.upsert;
    if(args.new !== undefined)
      q.new = args.new;
    var ret = this.findOne(q.query,q.options);
    if(args.remove){
      this.remove({_id: ret._id});
    }else{
      if(q.upsert)
        this.upsert({_id: ret._id}, q.update);
      else
        this.update({_id: ret._id}, q.update);
      if(q.new)
        ret = this.findOne({_id: ret._id}, q.options);
    }
    return ret;
  };
}