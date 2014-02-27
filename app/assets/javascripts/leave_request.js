$(document).ready(function() {
  $('[data-behaviour~=datepicker]').datepicker({
    autoclose: true,
    todayHighlight: true,
    todayBtn: "linked",
    format: "mm/dd/yyyy"
  });
});
