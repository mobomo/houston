jQuery ->
  $("a[rel=popover]").click (e) ->
    e.preventDefault()
    $('[rel=popover]').not(this).popover('hide')
    $(this).popover()
