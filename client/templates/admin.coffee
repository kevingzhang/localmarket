Template.admin.helpers
  isAdmin: ->
    Meteor.user() and Meteor.user().admin
  
  
  
Template.admin.events
  
  'click .login': (e,t)->
    user = t.find('#username').value
    password = t.find('#password').value

    Meteor.loginWithPassword user, password, (e,r)->
      if e?
        alert e.message
      console.log "login ok"


  'click .logout': ->
    Meteor.logout (e,r)->
      if e?
        alert e.message 
      console.log "logout ok"

  'click .register':(e,t)->
    user = t.find('#username').value
    password = t.find('#password').value
    email = t.find('#email').value 
    option = {
      username: user
      email: email
      password: password
      profile:{name:user}
    }
    Accounts.createUser option, (e,r)->
      if e?
        alert e.message 
      console.log "user created"



  'click #addStoreBtn': (e,t) ->
    storeName = (t.find '#addStoreInput').value
    return unless !!storeName
    address = (t.find '#addStoreAddress').value
    return unless !!address
    Meteor.call 'addNewStore', storeName, {storeName:storeName, storeAddress:address}, (e,r)->
      if e?
        console.log "ERROR: addNewStore:", e.message
      else
        #r is expectd to be the id of store
        alert "Store #{r} is added. Store name is #{storeName}"

  'click #addUserAccessToStore':(e,t)->
    userId = t.find('#userId').value
    storeId = t.find('#storeId').value
    right = t.find('#right').value
    Meteor.call 'addUserAccessToStore', userId, storeId, right, (e,r)->
      if e?
        alert e.message 
      console.log r 

  'click #removeUserAccessToStore':(e,t)->
    userId = t.find('#userId').value
    storeId = t.find('#storeId').value
    right = t.find('#right').value
    Meteor.call 'removeUserAccessToStore', userId, storeId, right, (e,r)->
      if e?
        alert e.message 
      console.log r 










