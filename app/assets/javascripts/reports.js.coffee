beginningOfWeek = (date) ->
  year = date.getFullYear()
  month = date.getMonth()
  day = date.getDate() - date.getDay() + 1

  new Date(year, month, day)

padNumber = (num) ->
  padding = if num < 10 then "0" else ""
  padding + num

formatDate = (date) ->
  "#{padNumber(date.getMonth() + 1)}/#{padNumber(date.getDate())}"

highlightCurrentWeek = (tableSelector) ->
  return unless $(tableSelector).length > 0

  dateInShort = formatDate beginningOfWeek(new Date())

  child = $("#{tableSelector} th[data-date='#{dateInShort}']")[0].cellIndex + 1
  $("#{tableSelector} > tbody > tr > th:nth-child(#{child}), #{tableSelector} > tbody > tr > td:nth-child(#{child})").addClass('current-week')

makeDeliveryBarChart = (container) ->
  remaining = container.data("remaining")
  used = container.data("used")
  expected = container.data("expected")
  total = remaining + used
  remaining_percent = (remaining / total)
  used_percent = (used / total)
  expected_percent = (expected / total)

  project_start = container.data("start")
  project_end = container.data("end")
  project_span = project_end - project_start
  project_span_percentage = 1000 / project_span

  $(container).highcharts
    chart:
      type: "bar"
      spacingBottom: 0
      spacingLeft: 0
      spacingRight: 0
      spacingTop: 0

    title:
      text: ""

    legend:
      enabled: false

    xAxis:
      lineWidth: 0
      tickWidth: 0
      labels:
        enabled: false

    yAxis:
      gridLineWidth: 0
      title: ""
      labels:
        enabled: false

    tooltip:
      enabled: false
      pointFormat: "{series.name}: <b>{point.y} hours</b>"

    plotOptions:
      series:
        stacking: "normal"
        enableMouseTracking: false

    series: [
      type: "bar"
      name: "Remaining"
      color: "#EFEFEF"
      dataLabels:
        color: "#CCC"

      data: [remaining_percent * 1000]
    ,
      type: "bar"
      name: "Used"
      color: "#D6E9C6"
      data: [used_percent * 1000]
    ]
  , (chart) ->

    # projected
    chart.yAxis[0].addPlotLine
      dashStyle: "dash"
      value: expected_percent * 1000
      color: "#468847"
      width: 2
      zIndex: 5

    # milestones
    $.each container.data("milestones"), (index, milestone) ->
      chart.yAxis[0].addPlotLine
        value: (milestone.timestamp - project_start) * project_span_percentage
        color: "#666"
        width: 1
        dashStyle: "dash"
        zIndex: 5
        label:
          text: "<b>" + milestone.label + "</b>"
          rotation: 0
          verticalAlign: "top"
          style:
            color: "#666"
            fontSize: "10px"

load "reports#index", (controller, action) ->
  $("#active-projects td.chart-green").each ->
      makeDeliveryBarChart $(this)

  $("td a.popover-trigger").each ->
    content = $(this).next(".popover-html")
    content.hide()
    title = $(this).html() + "'s schedule"
    $(this).popover({
      trigger: 'hover'
      html: true
      placement: 'right'
      title: title
      content: content.html()
      callback: ->
        highlightCurrentWeek "table.by-person table"
    })

  $("td.status a").each ->
    $(this).height = $(this).parent("td").height()
    $(this).tooltip({
      html: true
      placement: 'right'
    })

  $("#inactive-projects-toggle").click (e)->
    e.preventDefault()
    if $(".inactive-projects-container").is(":visible")
      $(this).text("Show inactive projects")
      $(".inactive-projects-container").hide()
    else
      $(this).text("Hide inactive projects")
      $(".inactive-projects-container").show()

  highlightCurrentWeek "table.by-person"
  highlightCurrentWeek "table.by-project"
