# Initialize a seed activity
Meteor.startup ->
  if Activities.find().count() is 0
    Activities.insert
      recipeName: 'summer-apricots-honey-panna-cotta'
      text: 'I substituted strawberries for apricots - incredible!'
      image: '/img/activity/activity-placeholder-strawberry-640x640.jpg'
      userAvatar: 'https://avatars3.githubusercontent.com/u/204768?v=2&s=400'
      userName: 'Matt Debergalis'
      place: 'SoMA, San Francisco'
      date: new Date
    
  
