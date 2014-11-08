// Uses the Npm request module directly as provided by the request local pkg
var callTwitter = function(options) {
  var config = Meteor.settings.twitter
  var userConfig = Meteor.user().services.twitter;

  options.oauth = {
    consumer_key: config.consumerKey,
    consumer_secret: config.secret,
    token: userConfig.accessToken,
    token_secret: userConfig.accessTokenSecret
  };

  return Request(options);
}

var tweetActivity = function(activity) {
  // creates the tweet text, optionally truncating to fit the appended text
  function appendTweet(text, append) {
    var MAX = 117; // Max size of tweet with image attached
    
    if ((text + append).length > MAX)
      return text.substring(0, (MAX - append.length - 3)) + '...' + append;
    else
      return text + append;
  }
  
  // we need to strip the "data:image/jpeg;base64," bit off the data url
  var image = activity.image.replace(/^data.*base64,/, '');

  var response = callTwitter({
    method: 'post',
    url: 'https://upload.twitter.com/1.1/media/upload.json',
    form: { media: image }
  });
  
  if (response.statusCode !== 200)
    throw new Meteor.Error(500, 'Unable to post image to twitter');

  var attachment = JSON.parse(response.body);
  
  var response = callTwitter({
    method: 'post',
    url: 'https://api.twitter.com/1.1/statuses/update.json',
    form: {
      status: appendTweet(activity.text, ' #localmarket'),
      media_ids: attachment.media_id_string
    }
  });

  if (response.statusCode !== 200)
    throw new Meteor.Error(500, 'Unable to create tweet');
}

var getLocationPlace = function(loc) {
  var url = 'https://api.twitter.com/1.1/geo/reverse_geocode.json'
    + '?granularity=neighborhood'
    + '&max_results=1'
    + '&accuracy=' + loc.coords.accuracy
    + '&lat=' + loc.coords.latitude
    + '&long=' + loc.coords.longitude;
  
  var response = callTwitter({ method: 'get', url: url });

  if (response.statusCode === 200) {
    var data = JSON.parse(response.body);
    var place = _.find(data.result.places, function(place) {
      return place.place_type === 'neighborhood';
    });
    
    return place && place.full_name;
  }
}



