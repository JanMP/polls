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