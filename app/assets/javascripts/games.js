$(function() {

    $('.leave-game-confirmation-btn').on('click', function() {
      var gameId = $('input:hidden').data('game-id');
      var playerColor = $(this).data('player-color');
      $('#leaveGameConfirmation').modal('hide');
      leaveGame(gameId, playerColor);
    });
    
    function leaveGame(gameId, playerColor) {
      if ( playerColor === 'white' ) {
        var playerLeaving = { game: { white_player_id: null } };
      } else {
        var playerLeaving = { game: { black_player_id: null } };
      }
      
      $.ajax({
        url: '/games/' + gameId,
        method: 'PUT',
        data: playerLeaving,
        success: function(data) {
          $(location).attr('href', data.redraw_game_url);
        }
      });
    }
  
});