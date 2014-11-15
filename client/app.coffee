console.log "App started"

App.Util={}
App.Util.validatePhoneNumber = (inputtxt) ->
 
  phoneno = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/
  if inputtxt.match(phoneno) then true else false



App.helpers = {
}

for key, helper of App.helpers
  Template.registerHelpr key, helper


resetNowFunc = ()->
  Session.set 'nowTime', new Date()
Meteor.setInterval resetNowFunc ,6000