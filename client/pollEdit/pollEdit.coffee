readForm = (tmplData) ->
  data = Session.get 'editPoll'
  data.title = tmplData.title.value
  data.question = tmplData.question.value
  for i in [0..data.answers.length-1]
    data["answers"][i]["text"] = tmplData["answers_#{i}_text"]["value"]
  Session.set 'editPoll', data

Template.pollEdit.onCreated ->
  this.autorun =>
    id = FlowRouter.getParam '_id'
    if id is 'new'
      poll = newPoll()
    else
      poll = Polls.findOne id
    if poll?
      unless poll.creatorId?
        poll.creatorId = this.userId
        poll.creatorName = Meteor.user().username
      unless poll.creationDate?
        poll.creationDate = new Date()
      Session.set 'editPoll', poll

Template.pollEdit.helpers
    
  poll : ->
    Session.get 'editPoll'

  
Template.pollEdit.events
  
  'keyup input' : (event) ->
    readForm event.target.form
  
  'submit' : (event) ->
    event.preventDefault()
    Meteor.call 'savePoll', this
    FlowRouter.go('/')

  'click .cancel-btn' : ->
    FlowRouter.go('/')
    
  'click .delete-btn' : (event) ->
    poll = Session.get 'editPoll'
    index = Number $(event.target).attr('index')
    poll.answers.splice index ,1
    Session.set 'editPoll', poll
    
  'click .add-btn' : (event) ->
    editPoll = Session.get 'editPoll'
    console.log event.target
    index = Number $(event.target).attr('index')
    editPoll.answers.splice index+1 ,0, {text:'', amount:0}
    Session.set 'editPoll', editPoll
      