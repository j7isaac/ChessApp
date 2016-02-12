class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :winning_player_id
      t.integer :black_player_id
      t.integer :white_player_id
      t.boolean :is_stalemate?

      t.timestamps
    end
    
    add_index :games, :black_player_id
    add_index :games, :white_player_id
  end
end
