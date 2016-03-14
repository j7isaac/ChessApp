$(function() {
  
  var game_id = $('input:hidden').data('game-id');
  
  var current_time_stamp = $('#chessboard').data('time-stamp');
  
  var firebase_database = new Firebase("https://thecheckmates-chess.firebaseio.com/");

  firebase_database.child("games/" + game_id).on("value", function(snapshot) {
    var updated_timestamp = snapshot.val().time_stamp
    
    if ( updated_timestamp > current_time_stamp ) {
      location.reload()
    }
  });  
  
});