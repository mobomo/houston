project_hours_summary = (project_hours) ->
  return 'TBD' unless project_hours? && project_hours.length > 0
  $(project_hours).map((i, ph) -> "#{ph.pname} (#{ph.hours})").toArray().join(', ')

get_schedules_summary = (daily_schedule) ->
  daily_schedule.data = [null, null, null, null, null] if daily_schedule.data.length == 0
  $(daily_schedule.data).map (i, project_hours) ->
    project_hours_summary(project_hours)

buildMyScheduleTemplate = (data) ->
  str = """
    <li><span>Mon</span><%= schedules_summary[0] %></li>
    <li><span>Tues</span><%= schedules_summary[1] %></li>
    <li><span>Wed</span><%= schedules_summary[2] %></li>
    <li><span>Thurs</span><%= schedules_summary[3] %></li>
    <li><span>Fri</span><%= schedules_summary[4] %></li>
  """

  _.template str,
    schedules_summary: get_schedules_summary(data)

initQuestionWidget = ->
  $.ajax '/api/pages/question',
    type: 'GET'
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log textStatus
    success: (data, textStatus, jqXHR) ->
      $(".question").html("<h3>" + data.title + "</h3>" +
        "<p><a href='" + data.url + "' >See answer</a></p>")

updateMyScheduleDropdown = (week) ->
  option = $(".my_schedule .dropdown-menu li[data-week=#{week}]")
  $('.my_schedule button').html("#{option.text()}<span class='caret'></span>").data('week', option.data('week'))
  $('.my_schedule .dropdown-menu li').show()
  option.hide()

loadMyScheduleForWeek = (week) ->
  url = '/api/daily_schedule?week=' + week

  $.ajax url,
    type: 'GET'
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log textStatus
    success: (data, textStatus, jqXHR) ->
      $('.my_schedule .progress').hide()
      $('#schedule').html(buildMyScheduleTemplate(data))
      updateMyScheduleDropdown(week)

initMyScheduleWidget = ->
  $('.my_schedule .dropdown-menu li').on 'click', (e) ->
    e.preventDefault()
    loadMyScheduleForWeek($(this).data('week'))

  loadMyScheduleForWeek($('.my_schedule button').data('week'))

load "dashboards#index", (controller, action) ->
  initQuestionWidget()
  initMyScheduleWidget()
