$(function() {
  var movingPiece;
  var data;
  var opportunityForPromotion = false;

  $('.movable-chess-piece').draggable({
    start: function() {
      movingPiece = this;
    }
  });
  
  $('.chessboard-space').droppable({
    drop: function() {
      var targetSpace = this;
      
      var gameId = $('input:hidden').data('game-id');

      var pieceId = $(movingPiece).data('id');
      var pieceType = $(movingPiece).data('type');

      var targetX = $(targetSpace).data('x-coordinate');
      var targetY = $(targetSpace).data('y-coordinate');

      var params = {
        gameId: gameId,
        pieceId: pieceId,
        pieceType: pieceType,
        x: targetX,
        y: targetY
      }

      buildPieceData(params);
      
      checkForPromotionOpportunity(params);

      if ( !opportunityForPromotion ) {
        updatePiece(gameId, pieceId);
      }
    }
  });
  
  function buildPieceData(params) {
    data = {
      piece: {
        id: params.pieceId,
        x_coordinate: params.x,
        y_coordinate: params.y
      }
    }
  }
  
  function checkForPromotionOpportunity(params) {
    if ( params.pieceType === 'Pawn' && ( params.x === 1 || params.x === 8 )) {
      presentPromotionOptions(params);
      opportunityForPromotion = true;
    }
  }
  
  function presentPromotionOptions(params) {
    var promotionOptionsModal = $('#promotionOptions');
    
    promotionOptionsModal.modal('show');
  
    choosePawnReplacement(promotionOptionsModal, function(new_piece_name) {
      data.piece.type = new_piece_name;
      updatePiece(params.gameId, params.pieceId);
    });
  }
  
  function choosePawnReplacement(promotionOptionsModal, callback) {
    $('#promotionOptions').on('click', 'input', function() {
      var new_piece_name = $(this).attr('name').charAt(0).toUpperCase() + $(this).attr('name').slice(1);
      promotionOptionsModal.modal('hide');
      callback( new_piece_name );
    });
  }
  
  function updatePiece(gameId, pieceId) {
    $.ajax({
      url: '/games/' + gameId + '/pieces/' + pieceId,
      method: 'PUT',
      data: data,
      success: function(data) {
        $(location).attr('href', data.redraw_game_url);
      }
    });
  }
});