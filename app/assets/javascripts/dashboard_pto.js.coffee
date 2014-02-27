buildPtoTemplate = (data) ->
  str = '''
      <div class="col-md-6 col-xs-4 person">
        <div class="thumb">
          <img src="<%= user.avatar_url %>">
        </div>
        <h5><%= user.name %></h5>
        <p>
          <% if (birthday == true) {%>
            Birthday
          <% } else if (anniversary == true) {%>
            Anniversary
          <% } else {%>
            Out
          <% }%>
          &nbsp;<%= pto_date %>
        </p>
      </div>
  '''

  _.template str, data

load "dashboards#index", (controller, action) ->
  $.ajax '/api/week_hours?pto=true',
    type: 'GET'
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log textStatus
      $('.happy_travels').append("<p>Failed to load travel schdedules.</p>")
      $('.happy_travels .scroller').hide()
    success: (data, textStatus, jqXHR) ->
      $('.pto-progress').hide()
      $.each data, (index, week_hour) ->
        if week_hour.current_week == true
          $('.pto_this_week').html(buildPtoTemplate(week_hour))
        else
          $('.pto_next_week').append(buildPtoTemplate(week_hour))

