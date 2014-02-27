buildAnnouncementTemplate = (data) ->
  str = '''
    <div class="alert alert-warning alert-dismissable">
      <div class="thumb">
        <img src="<%=thumbnail%>"></img>
      </div>
      <strong><%=date%></strong> <%=text%>
    </div>
  '''

  _.template str, data

updateComponents = (data) ->
  $('#alerts').show() if data.length > 0
  if data.length > 1
    $('.view-all').show()
  else
    $('.view-all').hide()

$('#alerts').on 'show.bs.dropdown', ->
  $("#alerts #alert_scroll").addClass('full')
  $('#alerts .alert').each (index, element) ->
    $(element).addClass('full')

$('#alerts').on 'hide.bs.dropdown', ->
  $("#alerts #alert_scroll").removeClass('full')
  $('#alerts .alert').each (index, element) ->
    $(element).removeClass('full')

load "dashboards#index", (controller, action) ->
  $.ajax '/api/announcements',
    type: 'GET'
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log textStatus
    success: (data, textStatus, jqXHR) ->
      updateComponents(data)
      $.each data, (index, announcement) ->
        $('#alert_scroll .wrap').append(buildAnnouncementTemplate(announcement))

      $('#alert_scroll').serialScroll
        items:'div',
        duration:1500,
        force:true,
        easing:'linear',
        lazy:true,
        interval:1,
        step:1