UI.registerHelper 'debug', ()->
  console.log "++++++++"
  console.dir @
  console.log "--------"

UI.registerHelper 'equals', (v1, v2)->
  return v1 is v2

UI.registerHelper 'sessionEqualtoTemplate' , ()->
  #console.log "sessionEqual, ", @sessionName, @templateTrue
  if  (Session.get @sessionName) is @sessionValue
    return Template[@templateTrue]
  else
    return Template[@templateFalse]

UI.registerHelper 'sessionEqualtoString', (sessionName, sessionValue, trueValue, falseValue)->
  #console.log "SessionEqualtoString #{sessionName}, #{sessionValue}, #{trueValue}, #{falseValue}"
  curSessionValue = Session.get sessionName

  if curSessionValue is sessionValue
    return trueValue
  else
    return falseValue

UI.registerHelper 'isSessionEquals', (sessionName, sessionValue)->
  (Session.get sessionName) is sessionValue

UI.registerHelper 'numeralHelper', (num, fmt)->
  if isNaN(num)
    return '-'
  else 
    return numeral(num).format(fmt)

UI.registerHelper 'momentTransFormater', (timeString, fmtIn, fmtOut)->
  return moment(timeString, fmtIn).format(fmtOut)

UI.registerHelper 'momentFormater', (dateTime, fmtOut)->
  return moment(dateTime).format(fmtOut)



