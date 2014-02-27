# =============================================
# Customized D3 popover plugin
# =============================================
(->
  annotate = (options, create) ->
    el = d3.select @

    move_tip = (selection)->
      left = 0
      top  = 0

      position = @ownerSVGElement.getBoundingClientRect()

      left = position.left
      top  = position.top

      left += options.left || 0
      top  += options.top  || 0

      left += window.scrollX
      top  += window.scrollY

      # maximal of left
      left = 900 if left > 900

      selection
        .style("left", "#{left}px")
        .style("top",  "#{top}px")
        .style("display","block")

    el.on "click", (d) ->
      d3.selectAll(".annotation").remove()
      tip = create()
      tip.classed("project_#{d.id}", true)
        .classed("annotation", true)
        .classed(options.gravity, true)
        .classed('fade', true)
        .style("display", "none")
      tip.append("div")
        .attr("class","arrow")
        .style("top", "15px")

      inner = -> tip.classed('in', true)
      setTimeout(inner,10)
      tip.style("display","").call(move_tip.bind(this))

  d3.selection.prototype.popover = (f) ->
    body = d3.select('body')

    @.each (d, i) ->
      options = f.apply @, arguments
      create_popover = ->
        tip = body.append("div")
          .classed("popover", true)
          .classed("project_popover", true)
        tip.append("div")
          .attr("class", "popover-content")
          .html(options.content)
        tip

      annotate.call @, options, create_popover

)(d3)


# =============================================
# Project model
# =============================================
class Project
  constructor: (data, barHeight) ->
    @height = barHeight
    @setup(data)

  setup: (data) ->
    @data         = data
    @id           = data.id
    @client       = data.client
    @name         = data.name
    @clientProjectName = "#{@client} - #{@name}"
    @status       = data.status || 'unknow'
    @hours        = data.hours

    # Sort reverse chronological
    @comments     = (new Comment(c) for c in data.comments).sort (a,b) -> b.date - a.date

    @signedDate   = new Date(data.date_signed)
    @kickOffDate  = new Date(data.date_kickoff)
    @targetDate   = new Date(data.date_target)
    @deliveryDate = new Date(data.date_delivered)

    @initTeams()
    @initTextAnchor()

  initTeams: ->
    @teams = []
    for teamName in ['PM', 'US', 'HTML/JS', 'Rails', 'Mobile', 'QA', 'Other']
      if users = @hours[teamName]
        results = []
        for user, hour of users
          results.push {user: user, hour: hour}
        results.sort (a, b) -> b.hour - a.hour
        results = _.map results, (i) -> "#{i.user} (#{i.hour})"
        @teams.push [teamName, results.join(", ")]

  initTextAnchor: ->
    today = new Date()
    if today > @deliveryDate
      @textAnchor = 'end'
    else
      @textAnchor = 'start'

  displayTargetDate: ->
    @targetDate.toString("ddd, MMM d")

  statusName: ->
    switch @status
      when 'red'      then '???'
      when 'yellow'   then 'hmm.'
      when 'green'    then 'All good!'
      when 'pipeline' then 'Pipeline'
      else 'n/a'

  isClientHasMultipleProject: ->
    Chart.clients[@client] > 1

  displayNameInBar: ->
    if @isClientHasMultipleProject()
      @clientProjectName
    else
      @client

  setRow: (row) -> @row = row

  rectX: (scale) ->
    x = scale @kickOffDate
    if x < 0 then 0 else x

  rectY: -> @height * (@row - 1)

  rectWidth: (scale) ->
    start = scale @kickOffDate
    start = 0 if start < 0

    if @deliveryDate >= Date.monday().add(21).week()
      end = Chart.width
    else
      end = scale @deliveryDate

    width = end - start

  textLabelX: (scale) ->
    switch @textAnchor
      when 'start'
        @rectX(scale) + 15
      when 'end'
        @rectX(scale) + @rectWidth(scale) - 15

# =============================================
# Project comment
# =============================================
class Comment
  constructor: (data) ->
    @data = data
    @week = data.week
    @date = new Date(@week)
    @formatedDate = @date.toString("M/dd")
    @user = data.user
    @text = data.text.replace(/[\n]/g, '<br/>')


# =============================================
# Draw chart start here
# =============================================
@Chart =
  svg: null
  clients: {}
  projects: []
  width: 0
  height: 0
  xScale: null
  topPadding: 10
  rectBarHeight: 36
  rectBarPadding: 10
  xAxisHeight: 30

  composeUrl: (client, user) ->
    params = {}

    switch client
      when 'internal' then params.internal = true
      when 'external' then params.internal = false
      when 'active' then params.active = true

    if user.match('group_')
      params.group = user.replace('group_', '')

    if user.match('team_')
      params.team = user.replace('team_', '')

    if user.match('user_id_')
      params.user_id = user.replace('user_id_', '')

    "/api/projects?#{$.param(params)}"

  load: (client='all', user='all') ->
    d3.json Chart.composeUrl(client, user), (data) ->
      Chart.removeGrid()
      Chart.populateProjects(data)

  populateProjects: (data) ->
    Chart.projects = (new Project(i, Chart.rectBarHeight) for i in data)
    Chart.populateClients()

    # init grid
    grid = []
    for i in [0...Chart.projects.length]
      grid[i] = []

    for project in Chart.projects
      insterted = false
      for row, i in grid
        break if insterted
        if lastProject = _.last(row)
          if project.kickOffDate > lastProject.deliveryDate
            insterted = true
            row.push project
            project.setRow i+1
        else
          insterted = true
          row.push project
          project.setRow i+1

    # remove empty row
    grid = _.filter grid, (row) ->
      not _.isEmpty(row)

    Chart.setWidth()
    Chart.setHeight(grid.length)
    Chart.setXScale()
    Chart.drawGrid()
    Chart.drawRects()
    Chart.drawXAxis()
    Chart.drawTodayLine()

  populateClients: ->
    Chart.clients = {} # reset Chart.clients
    for project in Chart.projects
      if Chart.clients[project.client]
        Chart.clients[project.client] = Chart.clients[project.client] + 1
      else
        Chart.clients[project.client] = 1

  setWidth: ->
    Chart.width = $('#main-vis').width()

  setHeight: (rowCount) ->
    Chart.height = Chart.topPadding +
                   Chart.rectBarHeight * rowCount +
                   Chart.xAxisHeight

  setXScale: ->
    begin = Date.monday().add(-4).week()
    end   = Date.monday().add(21).week()

    Chart.xScale = d3.time.scale()
      .domain([begin, end])
      .range([0, Chart.width])

  removeGrid: ->
    d3.select('.projects_chart').select('svg').remove()

  drawGrid: ->
    Chart.svg = d3.select('.projects_chart')
      .append('svg')
      .attr("width", Chart.width)
      .attr("height", Chart.height)

  popoverContentTemplate: (data) ->
    str = '''
    <div class="project_header clearfix">
      <span class="target_date">Target Delivery Date: <%= displayTargetDate() %></span>
      <span class="status">
        <label>Status:</label>
        <span class="status_pattern <%= status %>">&nbsp;</span>
        <span class="status_name"><%= statusName() %></span>
      </span>
    </div>
    <div class="project_info">
      <span><%= clientProjectName %></span>
    </div>
    <div class="project_hours">
      <% _.each(teams, function(team) { %>
        <div class="team clearfix">
          <label><%= team[0] %>:</label>
          <span class="user">
            <%= team[1] %>
          </span>
        </div>
      <% }) %>
    </div>
    <div class="project_comments">
      <% _.each(comments, function(comment) { %>
        <div class="comment clearfix">
          <label><%= comment.formatedDate %></label>
          <span>From <%= comment.user %>: <%= comment.text %></span>
        </div>
      <% }) %>
    </div>
    '''

    _.template str, data

  drawRects: ->
    rectGroup = Chart.svg.append("g")
      .attr("class", "bars")

    bars = rectGroup.selectAll("g")
      .data(Chart.projects).enter().append("g")
      .popover (d, i) ->
        content: Chart.popoverContentTemplate(d)
        gravity: "right"
        left: (d.rectX Chart.xScale) + (d.rectWidth Chart.xScale)
        top: d.rectY() + Chart.topPadding
        containerPosition: $('.projects_chart').position()

    bars.append("rect")
      .attr("class", (d) -> "project-bar status_#{d.status}")
      .attr("x", (d) -> d.rectX Chart.xScale )
      .attr("y", (d) -> d.rectY() + Chart.topPadding)
      .attr("height", Chart.rectBarHeight - Chart.rectBarPadding)
      .attr("width", (d) -> d.rectWidth Chart.xScale)
      .attr("rx", 3)
      .attr("ry", 3)
      .attr("stroke", "none")
      .attr("opacity", 0.8)

    bars.each (d, i) ->
      bbox = @getBBox()
      d3.select(@).append("defs").append("clipPath")
        .attr("id", (d) -> "clip-path-#{d.id}")
        .append("rect")
        .attr("x", bbox.x)
        .attr("y", bbox.y)
        .attr("height", bbox.height)
        .attr("width",  bbox.width)

    bars.append('text')
      .attr("class", (d) -> "status_#{d.status}")
      .attr("text-anchor", (d) -> d.textAnchor )
      .attr("x", (d) -> d.textLabelX(Chart.xScale))
      .attr("y", (d) -> d.rectY())
      .attr("dy", "2em")
      .text((d) -> d.displayNameInBar())
      .style("clip-path", (d) -> "url(#clip-path-#{d.id})")

  drawXAxis: ->
    days  = []
    begin = Date.monday().add(-4).week()
    end   = Date.monday().add(21).week()
    while begin <= end
      days.push new Date(begin)
      begin = begin.add(1).day()

    axis = d3.svg.axis()
      .scale(Chart.xScale)
      .orient('bottom')
      .ticks(d3.time.months)
      .tickFormat(d3.time.format("%b"))

    Chart.svg.append("g")
      .selectAll('circle')
      .data(days).enter().append('circle')
      .attr('cx', (d) -> Chart.xScale(d))
      .attr('cy', Chart.height - Chart.xAxisHeight)
      .attr('r', '1.5')
      .attr('fill', '#454b51')
      .attr('stroke', '#454b51')

    Chart.svg.append('g')
      .attr("class", "x-axis")
      .attr("transform", "translate(0," + (Chart.height - Chart.xAxisHeight) + ")")
      .call(axis)
      .selectAll(".tick text")
      .attr("x", 115)
      .attr("y", 15)


  drawTodayLine: ->
    tip = Chart.svg.append('g')
      .attr('class', 'today-tip')

    tip.append("svg:line")
      .attr("class", "today-line")
      .attr("x1", Chart.xScale(Date.today()))
      .attr("x2", Chart.xScale(Date.today()))
      .attr("y1", Chart.topPadding)
      .attr("y2", Chart.height - Chart.xAxisHeight)
      .attr("stroke", '#454b51')

    tip.append('rect')
      .attr("class", "today-bg")
      .attr('x', Chart.xScale(new Date()) - 25)
      .attr('width', 50)
      .attr('height', 14)

    tip.append('text')
      .attr('x', Chart.xScale(new Date()))
      .attr('y', 10)
      .attr('fill', 'white')
      .attr('text-anchor', 'middle')
      .text('Today')

load "dashboards#index", (controller, action) ->
  # Draw projects chart by default parameters
  Chart.load('all', 'all')

  $('.vis-header select').on 'change', ->
    client = $('select#client').val()
    user   = $('select#user').val()
    Chart.load(client, user)

  # Close chart popover when click outside of the popover
  $('.projects_chart').on 'click', (e) ->
    if e.target.tagName is 'svg'
      $('.popover.annotation').remove()
