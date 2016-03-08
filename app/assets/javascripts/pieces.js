$(function() {
  
  var moving_piece;

  $('.chess-piece').draggable({
    start: function() {
      moving_piece = this;
    }
  });
  
  $('.chessboard-space').droppable({
    drop: function() {
      var target_space = this;
      
      var game_id = $('input:hidden').data('game-id');
      var piece_id = $(moving_piece).data('id');

      var target_x = $(target_space).data('x-coordinate');
      var target_y = $(target_space).data('y-coordinate');
      
      $.ajax({
        url: '/games/' + game_id + '/pieces/' + piece_id,
        method: 'PUT',
        data: {
          piece: {
            id: piece_id,
            x_coordinate: target_x,
            y_coordinate: target_y
          }
        },
        success: function(data) {
          $(location).attr('href', data.redraw_game_url);
        }
      });
    }
  });
  
});