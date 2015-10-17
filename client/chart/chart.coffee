drawChart = ->
  
  poll = Template.currentData()
  
  data =
    labels : ({i : i, a : answer.amount} for answer, i in poll.answers)
    series : (Number(answer.amount) for answer in poll.answers)
  
  selector = "#chart-#{poll._id}"
  
  options =
    labelInterpolationFnc : (value) ->

      percentage = Math.round value.a / data.series.reduce((a,b)->a+b) * 100
      if percentage < 1
        return ''
      else
        return "#{ordinalLetter value.i}: #{percentage}%"
    

  unless $(selector).length
    console.log "$('#{selector}') not found"
    return
  
  console.log "drawing #{selector}"
  pieChart = new Chartist.Pie(selector, data, options)

Template.chart.onRendered ->
  this.autorun drawChart