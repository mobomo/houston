// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require modernizr-2.6.2.min
//= require bootstrap.min
//= require chosen.jquery
//= require underscore-min
//= require jquery.purr
//= require best_in_place
//= require date
//= require d3.min
//= require jquery.scrollTo.min
//= require jquery.serialScroll.min
//= require highcharts-min
//= require highcharts-more
//= require cocoon
//= require loadjs

//= require dashboard
//= require dashboard_projects_chart
//= require reports
//= require schedules
//= require bootstrap-datepicker
//= require leave_request
//= require dashboard_pto
//= require announcements

$(document).ready(function() {
  /* Activating Best In Place */
  $(".best_in_place").best_in_place();

  $('.chzn-select').chosen();

  $('.dropdown-toggle').dropdown();
});
