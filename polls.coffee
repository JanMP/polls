Polls = new Mongo.Collection 'polls'

if Meteor.isClient

  newPoll = ->
    title : ''
    question : ''
    #creatorName : ''
    #creatorId : ''
    #creationDate : new Date()
    answers : [
      text : ''
      amount : 0
    ,
      text : ''
      amount : 0
    ]
    haveVoted : []

  readForm = (tmplData) ->
    data = Session.get 'editPoll'
    data.title = tmplData.title.value
    data.question = tmplData.question.value
    for i in [0..data.answers.length-1]
      data["answers"][i]["text"] = tmplData["answers_#{i}_text"]["value"]
    Session.set 'editPoll', data
  
  
  Meteor.startup ->
    Session.set 'editPoll', newPoll()

  
  Template.registerHelper 'withIndex', (list)->
    withIndex = _.map list, (v, i) ->
      index : i
      numberIndex : i+1
      letterIndex : if i <= 25 then String.fromCharCode(i + 65) else i+1
      name : "answers_#{i}_text"
      value : v

  Template.pollVote.helpers

    votePoll : ->
      Session.get 'votePoll'


  Template.pollVote.events

    'submit' : (event, template) ->
      event.preventDefault()
      poll = Session.get 'votePoll'
      console.log 'template', template.find('input:radio')
      result = Number template.find('input:radio[name=answers]:checked').value
      Meteor.call 'vote', poll._id, result
      Router.go '/'

    'click .cancel-btn' : ->
      Router.go '/'
  
  Template.pollEdit.helpers
    
    editPoll : ->
      poll = Session.get 'editPoll'
      unless poll.creatorId?
        poll.creatorId = this.userId
        poll.creatorName = Meteor.user().username
      unless poll.creationDate?
        poll.creationDate = new Date()
      return poll

  
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
    
    fromNow : ->
      moment(this.creationDate).fromNow()
    
    mayNotEdit : ->
      not Meteor.userId() or this.creatorId isnt Meteor.userId()

    mayNotVote : ->
      not Meteor.userId() or _.contains this.haveVoted, Meteor.userId()

  
  Template.pollDisplay.events
  
    'click .vote-btn' : ->
      Session.set 'votePoll', Polls.findOne(this._id)
      Router.go "/vote"
  
    'click .edit-btn' : ->
      Session.set 'editPoll', Polls.findOne(this._id)
      Router.go "/edit"
  
    'click .delete-btn' : ->
      Meteor.call 'deletePoll', this._id

  
  Template.polls.helpers
  
    mayNotCreate : ->
      not Meteor.userId()
      
  
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
  
  Router.route '/vote',
    template : 'pollVote'

  Router.route '/vote/:_id', ->
    poll = Polls.findOne this.params._id
    console.log 'poll', poll
    this.render 'pollVote',
      data : -> poll
        
      

  
  Accounts.ui.config
    passwordSignupFields: "USERNAME_AND_EMAIL"

#/if Meteor.isClient

Meteor.methods
  
  vote : (pollId, result) ->
    poll = Polls.findOne(pollId)
    unless this.userId
      throw new Meteor.Error 'logged-out', 'must be logged in to vote'
    if _.contains poll.haveVoted, this.userId
      throw new Meteor.Error 'has-Voted', 'you may only vote once'
    Polls.update pollId,
      $inc :
        "answers.#{result}.amount" : 1
      $push :
        haveVoted : this.userId

  savePoll : (poll) ->
    unless this.userId
      throw new Meteor.Error 'logged-out', 'must be logged in to save Polls'
    unless poll.creatorId?
      poll.creatorId = this.userId
      poll.creatorName = Meteor.user().username
    unless poll.creationDate?
      poll.creationDate = new Date()
    Polls.upsert poll._id, poll
   
  deletePoll : (pollId) ->
    poll = Polls.findOne(pollId)
    unless this.userId
      throw new Meteor.Error 'logged-out', 'must be logged in to delete Polls'
    unless poll.creatorId is this.userId
      throw new Meteor.Error 'not-the-owner', 'can only delete your own Polls'
    Polls.remove pollId

