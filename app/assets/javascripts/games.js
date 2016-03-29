$(function() {

    $('.leave-game-confirmation-btn').on('click', function() {
      var playerID = $(this).val();
      $('#leaveGameConfirmation').modal('hide');
      leaveGame(playerID);
    });
    
    function leaveGame() {
      
    }
  
});