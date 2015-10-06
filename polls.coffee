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
    amoount : 0
  ]


if Meteor.isClient
  Session.setDefault 'page', 'listing'
  Forms.mixin(Template.pollEdit)

  Template.registerHelper 'withIndexAndName', (name, list)->
    withIndex = _.map list, (v, i) ->
      index : i
      name : "#{name}#{i}"
      value : v
      
    console.log withIndex
    return withIndex

  Template.polls.helpers
    polls : ->
      Polls.find {}
    showEdit : ->
      Session.get('page') is 'edit'
    showListing : ->
      Session.get('page') is 'listing'

  Template.polls.events
    'click .new-poll-btn' : ->
      Session.set 'page', 'edit'
      Session.set 'editPoll', newPoll()

  Template.pollEdit.helpers
    editPoll : ->
      Session.get 'editPoll'

  Template.pollEdit.events
    'documentSubmit' : (event, tmpl, doc) ->
      console.log 'submitting'
      console.log doc
      #Session.set 'page', 'listing'
    'click .delete-btn' : (event) ->
      index = event.target.getAttribute 'index'
      editPoll = Session.get 'editPoll'
      console.log editPoll
    'propertyChange' : (event, template, changes)->
      console.log changes
      
    'click .cancel-btn' : ->
      Session.set 'page' : 'listing'

  Template.pollDisplay.helpers
    mayNotEdit : ->
      false
    mayNotVote : ->
      false

  Template.pollDisplay.events
    'click .vote-btn' : ->
      Meteor.call 'vote', this._id
    'click .edit-btn' : ->
      Meteor.call 'editPoll', this._id
    'click .delete-btn' : ->
      Meteor.call 'deletePoll', this._id

Meteor.methods
  newPoll : ->
    Session.set 'page', 'edit'
    Session.set 'editPoll', newPoll()
  vote : (pollId) ->
    alert "vote on poll #{pollId}"
  editPoll : (pollId) ->
    Session.set 'page', 'edit'
    #Session.set 'editPoll', Polls.findBy
  savePoll : ->
    Session.set 'page', 'listing'
    Polls.insert(Session.get 'editPoll')
  deletePoll : (pollId) ->
    Polls.remove pollId

Router.configure
  layoutTemplate : 'layout'

Router.route '/',
  template : 'polls'

Router.route '/about',
  template : 'about'

###
if Meteor.isClient
  Session.setDefault 'counter', 0
  console.log "counter: #{Session.get 'counter'}"

  Template.hello.helpers
    counter : ->
      Session.get 'counter'

  Template.hello.events
    'click button' : ->
      Session.set 'counter', Session.get('counter') + 1

if Meteor.isServer
  Meteor.startup ->
    console.log 'server startup'
###