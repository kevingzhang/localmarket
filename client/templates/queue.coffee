Template.queue.helpers
  storeQueue: () ->
    array = []
    for i in [1..12]
      array.push {
        _id:0
        displayFakeName : "(XXX)XXX-2288"
        partyOf: 3
        waitTime: '2:34'

      }
    return array
    # ...

Template.queue.events
  'click .openLogin': () ->
    Overlay.open('addMeIn', this);
    # ...