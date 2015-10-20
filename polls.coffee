

if Meteor.isClient

  Meteor.subscribe 'polls'
  
  Meteor.startup ->
    Session.set 'editPoll', newPoll()

  Template.registerHelper 'ordinal', (i) -> i + 1

  @ordinalLetter = (i) ->
    if i < 26 then String.fromCharCode(i + 65) else i+1
  
  Template.registerHelper 'ordinalLetter', ordinalLetter
  
  Template.registerHelper 'isActiveRoute', (str) ->
    str is FlowRouter.getRouteName()

  
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
    if poll._id?
      Polls.update poll._id, {$set : poll}
    else
      Polls.insert poll
    ###
    unless poll.creatorId?
      poll.creatorId = this.userId
      poll.creatorName = Meteor.user().username
    unless poll.creationDate?
      poll.creationDate = new Date()
    if poll._id?
      Polls.update poll._id, poll
    else
      Polls.insert poll
    ###

  deletePoll : (pollId) ->
    poll = Polls.findOne(pollId)
    unless this.userId
      throw new Meteor.Error 'logged-out', 'must be logged in to delete Polls'
    unless poll.creatorId is this.userId
      throw new Meteor.Error 'not-the-owner', 'can only delete your own Polls'
    Polls.remove pollId

