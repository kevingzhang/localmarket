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

  
