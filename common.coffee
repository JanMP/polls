@Polls = new Mongo.Collection 'polls'

@PollSchema = new SimpleSchema
  title :
    type : String
    min : 3
    max : 30
  question :
    type : String
    min : 3
    max : 80
  answers :
    type : [Object]
    minCount : 2
    maxCount : 26
  'answers.$.text' :
    type : String
    min : 1
    max : 160
  'answers.$.amount' :
    type : Number
    defaultValue : 0
  creatorName :
    type : String
  creatorId :
    type : String
    autoValue : ->
      if this.isInsert
        return this.userId
  creationDate :
    type : Date
    autoValue : ->
      if this.isInsert
        return new Date()
      else if this.isUpsert
        return {$setOnInsert : new Date()}
  haveVoted :
    type : [String]

Polls.attachSchema(PollSchema)


@newPoll = ->
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
