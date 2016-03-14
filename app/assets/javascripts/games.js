$(function() {
  
  var game_id = $('input:hidden').data('game-id');
  
  var current_time_stamp = $('#chessboard').data('time-stamp');

// Opens connection to Firebase database for project
  var firebase_database = new Firebase("https://thecheckmates-chess.firebaseio.com/");

// Triggers when a player finishes their turn
  firebase_database.child("games/" + game_id).on("value", function(snapshot) {
  // Grabs the time_stamp portion of the JSON object returned by Firebase
    var updated_timestamp = snapshot.val().time_stamp

  // Check the time_stamp returned by Firebase is more recent than the game's time-stamp
    if ( updated_timestamp > current_time_stamp ) {
    // Refresh each player's browser
      location.reload()
    }
  });  
  
});