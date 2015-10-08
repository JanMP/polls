Polls = new Mongo.Collection 'polls'

newPoll = ->
  title : ''
  question : ''
  creatorName : ''
  creatorId : ''
  answers : [
    text : ''
    amount : 0
  ,
    text : ''
    amount : 0
  ]

readForm = (tmplData) ->
  data = Session.get 'editPoll'
  data.title = tmplData.title.value
  data.question = tmplData.question.value
  for i in [0..data.answers.length-1]
    data["answers"][i]["text"] = tmplData["answers_#{i}_text"]["value"]
  Session.set 'editPoll', data
  
if Meteor.isClient
  
  Meteor.startup ->
    Session.set 'editPoll', newPoll()


  Template.registerHelper 'withIndex', (list)->
    withIndex = _.map list, (v, i) ->
      index : i
      numberIndex : i+1
      letterIndex : if i <= 25 then String.fromCharCode(i + 65) else i+1
      name : "answers_#{i}_text"
      value : v

  Template.pollEdit.helpers
    editPoll : ->
      Session.get 'editPoll'

  Template.pollEdit.events
    
    'keyup input' : (event)->
      readForm event.target.form
    
    'submit' : (event) ->
      event.preventDefault()
      Meteor.call 'savePoll', Session.get('editPoll')
      Session.set 'editPoll', newPoll()
      Router.go('/')

    'click .cancel-btn' : ->
      Session.set 'editPoll', newPoll()
      Router.go('/')
      
    'click .delete-btn' : (event) ->
      editPoll = Session.get 'editPoll'
      index = this.index
      editPoll.answers.splice index ,1
      Session.set 'editPoll', editPoll
      
    'click .add-btn' : (event) ->
      editPoll = Session.get 'editPoll'
      index = this.index
      editPoll.answers.splice index+1 ,0, {text:'', amount:0}
      Session.set 'editPoll', editPoll
      
    

  Template.pollDisplay.helpers
    mayNotEdit : ->
      false
    mayNotVote : ->
      false

  Template.pollDisplay.events
    'click .vote-btn' : ->
      Meteor.call 'vote', this._id
    'click .edit-btn' : ->
      Session.set 'editPoll', Polls.findOne(this._id)
      Router.go "/edit"
    'click .delete-btn' : ->
      Meteor.call 'deletePoll', this._id

  Router.configure
    layoutTemplate : 'layout'

  Router.route '/',
    template : 'polls'
    data :
      polls : Polls.find()
      
  Router.route '/about',
    template : 'about'

  Router.route '/edit',
    template : 'pollEdit'
    data : newPoll()

#/if Meteor.isClient

Meteor.methods
  vote : (pollId) ->
    alert "vote on poll #{pollId}"
  savePoll : (poll) ->
    Polls.upsert poll._id, poll
  deletePoll : (pollId) ->
    Polls.remove pollId