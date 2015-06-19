// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery2
//= require jquery_ujs
//= require bootstrap-sprockets
//= require moment
//= require bootstrap-datetimepicker
//= require bootstrap-material-design
//= require turbolinks
//= require_tree .

$(document).on('ready page:load',function(){
  $.material.init();
  $('input[data-disable-with="null"]').each(function(){
    var j_this = $(this);
    j_this.attr('data-disable-with',j_this.val());
  });
});
