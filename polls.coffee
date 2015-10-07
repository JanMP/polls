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

readForm = (data, form) ->
  data.poll.title = form.title.value
  data.poll.question = form.question.value
  for i in [0..data.poll.answers.length-1]
    data.poll["answers"][i]["text"] = form["answers_#{i}_text"]["value"]
  data.dep.changed()
  console.log 'changed:', data
  

if Meteor.isClient

  Template.registerHelper 'withIndex', (list)->
    withIndex = _.map list, (v, i) ->
      index : i
      numberIndex : i+1
      letterIndex : if i <= 25 then String.fromCharCode(i + 65) else i+1
      name : "answers_#{i}_text"
      value : v

  Template.pollEdit.helpers
    dummy : ->
      this.dep.depend()
      console.log 'depend (dummy):', this

  Template.pollEdit.events
    'submit' : (event) ->
      event.preventDefault()
      readForm this, event.target
      console.log 'Submitting:', this
      
    'click .delete-btn' : (event) ->
      Template.parentData().dep.depend()
      index = this.index
      Template.parentData().poll.answers.splice Number(index),1
      Template.parentData().dep.changed()
      
    'click .add-btn' : (event) ->
      index = this.index
      me = Template.parentData().poll.answers[index].text
      console.log "me", me
      me = "suck(#{me})"
      console.log "me", me
      
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
    #'click .edit-btn' : ->
    #  Meteor.call 'editPoll', this._id
    'click .delete-btn' : ->
      Meteor.call 'deletePoll', this._id

Meteor.methods
  vote : (pollId) ->
    alert "vote on poll #{pollId}"
  savePoll : (poll) ->
    Polls.upsert poll
  deletePoll : (pollId) ->
    Polls.remove pollId

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
  data :
    dep : new Tracker.Dependency
    poll : newPoll()

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