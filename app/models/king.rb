class King < Piece
    
    def valid_move?(x, y)
        delta_x = (x - x_coordinate).abs #where x is the new position, and x_coordinate is the previous position, .abs to ensure value is not negative
        delta_y = (y - y_coordinate).abs #where y is the new position, and y_coordinate is the previous position, .abs to ensure value is not negative
        
        delta_x <= 1 && delta_y <= 1
    end        
end
