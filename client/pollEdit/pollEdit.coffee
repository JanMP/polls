_ = lodash

schema = PollSchema.newContext('pollEdit')


validateInputs = ->
  poll = Session.get "editPoll"
  PollSchema.clean poll
  schema.validate poll
  Session.set "editPoll", poll
  for key in schema.invalidKeys()
    $("input[name='#{key.name}']").parent().addClass("has-error")


readInput = (target) ->
  poll = Session.get "editPoll"
  keys = target.name.split "."
  evalStr = "poll"
  for key in keys
    evalStr += if isNaN key then "['#{key}']" else "[#{Number key}]"
  if typeof target.value is "string"
    evalStr += "= target.value"
  eval evalStr
  if schema.validateOne poll, target.name
    $(target).parent().removeClass("has-error")
  else
    $(target).parent().addClass("has-error")
  Session.set "editPoll", poll


Template.pollEdit.onCreated ->
  this.autorun =>
    id = FlowRouter.getParam "_id"
    if id is "new"
      poll = newPoll()
    else
      poll = Polls.findOne id
    if poll?
      unless poll.creatorId?
        poll.creatorId = this.userId
        poll.creatorName = Meteor.user().username \
        or Meteor.user().profile.name or "[fnord]"
      unless poll.creationDate?
        poll.creationDate = new Date()
      Session.set "editPoll", poll
 

Template.pollEdit.onRendered ->
  validateInputs()
  

Template.pollEdit.helpers
    
  poll : ->
    Session.get "editPoll"

  invalidText : (key, index = -1) ->
    if index > -1
      keyArr = key.split "."
      for str, i in keyArr
        if str is "{{@index}}" then keyArr[i] = index
      key = keyArr.join(".")
    schema.keyErrorMessage key

  
Template.pollEdit.events
  
  "keyup input" : (event) ->
    readInput event.target
  
  "submit" : (event) ->
    event.preventDefault()
    validateInputs()
    Meteor.call "savePoll", this, (error, result) ->
      unless error
        FlowRouter.go("/")

  "click .cancel-btn" : ->
    FlowRouter.go("/")
    
  "click .delete-btn" : (event) ->
    poll = Session.get "editPoll"
    if poll.answers.length > 2
      index = Number $(event.target).attr("index")
      poll.answers.splice index ,1
      Session.set "editPoll", poll
    
  "click .add-btn" : (event) ->
    editPoll = Session.get "editPoll"
    index = Number $(event.target).attr("index")
    editPoll.answers.splice index+1 ,0, {text: "", amount:0}
    Session.set "editPoll", editPoll
      