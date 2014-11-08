#// Handle for launch screen possibly dismissed from app-body.js


#// Global subscriptions
if Meteor.isClient
  Meteor.subscribe('news');
  Meteor.subscribe('bookmarkCounts');
  feedSubscription = Meteor.subscribe('feed');


Router.configure
  layoutTemplate: 'appBody',
  notFoundTemplate: 'notFound'



  # // Keep showing the launch screen on mobile devices until we have loaded
  # // the app's data
@dataReadyHold = LaunchScreen.hold()

class @HomeController extends RouteController
  onBeforeAction: ->
    Meteor.subscribe 'latestActivity', ()->
      dataReadyHold.release()
    
    @next()


class @FeedController extends RouteController
  onBeforeAction: ->
    @feedSubscription = feedSubscription
    @next()

class @RecipesController extends RouteController
  data: ->
    return _.values(RecipesData)
  
class @BookmarksController extends RouteController
  onBeforeAction: ->
    if Meteor.user()
      Meteor.subscribe('bookmarks')
    else
      Overlay.open('authOverlay')
    @next()
  
  data: ->
    if Meteor.user()
      return _.values(_.pick(RecipesData, Meteor.user().bookmarkedRecipeNames));

class @RecipeController extends RouteController
  onBeforeAction: ->
    Meteor.subscribe 'recipe', @params.name
    @next();
  
  data: ->
    return RecipesData[@params.name];
  

class @AdminController extends RouteController
  onBeforeAction: ->
    Meteor.subscribe('news');
    @next();
  
Router.configure

Router.route '/',
  name:'home'

Router.route '/feed',
  name:'feed'

Router.route '/receipes',
  name:'recipes'

Router.route '/bookmarks',
  name:'bookmarks'

Router.route '/about',
  name:'about'

Router.route '/recipes/:name',
  name:'recipe'

Router.route '/admin',
  name:'admin'


Router.onBeforeAction('dataNotFound', {only: 'recipe'});