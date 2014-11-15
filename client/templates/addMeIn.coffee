Template.addMeIn.events
  'click #addMeButton': (e,t) ->
    phoneNumber = (t.find '#addMePhoneNumber').value
    email = (t.find '#addMeEmail').value
    
    partyOfNumber = (t.find '#addMePartyOf').value
    return unless !!partyOfNumber

    e = t.data.onOk phoneNumber, email, partyOfNumber
    if e?
      alert (e)
    else
      Overlay.close();


