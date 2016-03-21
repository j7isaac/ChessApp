$(function() {
  var movingPiece;
  var pieceUpdateData;
  var opportunityForPromotion = false;

  $('.movable-chess-piece').draggable({
    start: function() {
      movingPiece = this;
      $(movingPiece).css('z-index', 1);
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
    pieceUpdateData = {
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
  // Store reference to the jQuery representation of the promotion options modal
    var promotionOptionsModal = $('#promotionOptions');

  // Present the promotion options modal
    promotionOptionsModal.modal('show');
  
  // Send promotions options modal reference and callback function to choosePawnReplacement
    choosePawnReplacement(promotionOptionsModal, function(new_piece_name) {
      pieceUpdateData.piece.type = new_piece_name;
      updatePiece(params.gameId, params.pieceId);
    });
  }
  
  function choosePawnReplacement(promotionOptionsModal, callback) {
  // Delegate click event to whatever input (i.e. promotion option) element is chosen
    promotionOptionsModal.on('click', 'input', function() {
    // Store value of name attribute of chosen promotion option
      var new_piece_name = $(this).attr('name').charAt(0).toUpperCase() + $(this).attr('name').slice(1);
      promotionOptionsModal.modal('hide');
    /* Invoke the passed callback function to attach the chosen promotion option to the
       pieceUpdateData object and send it to pieces#update 
       *Note* a callback is used to ensure that pieces#update isn't called too soon */
      callback( new_piece_name );
    });
  }
  
  function updatePiece(gameId, pieceId) {
    $.ajax({
      url: '/games/' + gameId + '/pieces/' + pieceId,
      method: 'PUT',
      data: pieceUpdateData,
      success: function(data) {
        $(location).attr('href', data.redraw_game_url);
      }
    });
  }
});