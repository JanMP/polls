Polls = new Mongo.Collection 'polls'

if Meteor.isClient

  Meteor.subscribe 'polls'

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

  ###
  Template.registerHelper 'withIndex', (list)->
    withIndex = _.map list, (v, i) ->
      index : i
      numberIndex : i+1
      letterIndex : if i <= 25 then String.fromCharCode(i + 65) else i+1
      name : "answers_#{i}_text"
      value : v
  ###

  Template.registerHelper 'ordinal', (i) -> i + 1

  @ordinalLetter = (i) ->
    if i < 26 then String.fromCharCode(i + 65) else i+1
  
  Template.registerHelper 'ordinalLetter', ordinalLetter
  
  Template.registerHelper 'isActiveRoute', (str) ->
    str is FlowRouter.getRouteName()

  Template.pollVote.helpers
    
    poll : ->
      pollId = FlowRouter.getParam '_id'
      Polls.findOne pollId

  
  Template.pollVote.events

    'submit' : (event, template) ->
      event.preventDefault()
      result = Number template.find('input:radio[name=answers]:checked').value
      Meteor.call 'vote', this._id, result
      FlowRouter.go '/'

    'click .cancel-btn' : ->
      FlowRouter.go '/'
  

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
      
  
  Template.pollDisplay.helpers
    
    fromNow : ->
      moment(this.creationDate).fromNow()
    
    mayNotEdit : ->
      not Meteor.userId() or this.creatorId isnt Meteor.userId()

    mayNotVote : ->
      not Meteor.userId() or _.contains this.haveVoted, Meteor.userId()

  
  Template.pollDisplay.events
  
    'click .vote-btn' : ->
      #Session.set 'votePoll', Polls.findOne(this._id)
      FlowRouter.go "/vote/#{this._id}"
  
    'click .edit-btn' : ->
      #Session.set 'editPoll', Polls.findOne(this._id)
      FlowRouter.go "/edit/#{this._id}"
  
    'click .delete-btn' : ->
      Meteor.call 'deletePoll', this._id

  Template.pollDisplay.pieChart = ->
    console.log this
    plotOptions :
      pie :
        allowPointSelect : true
        cursor : 'pointer'
    title : this.title
    series : [
      type : 'pie'
      name : 'answers'
      data : this.answers.map (answer, index) ->
        ["#{ordinalLetter(index)}", answer.amount]
    ]
  
  Template.polls.helpers

    polls : Polls.find()
  
    mayNotCreate : ->
      not Meteor.userId()
      

  FlowRouter.route '/',
    name : 'home'
    action : ->
      BlazeLayout.render 'layout',
        content : 'polls'

  FlowRouter.route '/about',
    action : ->
      BlazeLayout.render 'layout',
        content : 'about'

  FlowRouter.route '/edit/:_id',
    action : ->
      BlazeLayout.render 'layout',
        content : 'pollEdit'

  FlowRouter.route '/vote/:_id',
    action : ->
      BlazeLayout.render 'layout',
        content : 'pollVote'


  Accounts.ui.config
    passwordSignupFields: "USERNAME_AND_EMAIL"

if Meteor.isServer

  Meteor.publish 'polls', ->
    Polls.find()
  

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
    if poll._id?
      Polls.update poll._id, poll
    else
      Polls.insert poll
   
  deletePoll : (pollId) ->
    poll = Polls.findOne(pollId)
    unless this.userId
      throw new Meteor.Error 'logged-out', 'must be logged in to delete Polls'
    unless poll.creatorId is this.userId
      throw new Meteor.Error 'not-the-owner', 'can only delete your own Polls'
    Polls.remove pollId

