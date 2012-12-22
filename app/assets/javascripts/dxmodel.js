$(document).ready(function() {

  // Enter position form fields
  $( "#position_enter_date" ).datepicker({ dateFormat: "yy-mm-dd" });

  calc_enter_local_value = function(){
    $('#position_enter_local_value').val( $('#position_quantity').val() * $('#position_enter_local_price').val() );
  }

  calc_enter_usd_value = function(){
    $('#position_enter_usd_value').val( $('#position_enter_local_value').val() / $('#position_enter_usd_fx_rate').val() );
  }

  $('#position_quantity, #position_enter_local_price').keyup( calc_enter_local_value );
  $('#position_enter_usd_fx_rate, #position_enter_local_value').keyup( calc_enter_usd_value );



  // Exit position form fields
  $( "#position_exit_date" ).datepicker({ dateFormat: "yy-mm-dd" });

  calc_exit_local_value = function(){
    $('#position_exit_local_value').val( $('#position_quantity').val() * $('#position_exit_local_price').val() );
  }

  calc_exit_usd_value = function(){
    $('#position_exit_usd_value').val( $('#position_exit_local_value').val() / $('#position_exit_usd_fx_rate').val() );
  }

  $('#position_quantity, #position_exit_local_price').keyup( calc_exit_local_value );
  $('#position_exit_usd_fx_rate, #position_exit_local_value').keyup( calc_exit_usd_value );

})

