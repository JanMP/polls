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
