class King < Piece
    
    def valid_move?
        king_move? == true && check? != true && is_obstructed? != true #checking if move falls within boundary of king's move (king_move? method) and if king is not moving into a check position (check? method) 
    end
    
    def king_move?(x, y)
        delta_x = (x - x_coordinate).abs #where x is the new position, and x_coordinate is the previous position, .abs to ensure value is not negative
        delta_y = (y - y_coordinate).abs #where y is the new position, and y_coordinate is the previous position, .abs to ensure value is not negative
        
        delta_x <= 1 && delta_y <= 1
    end        
end
