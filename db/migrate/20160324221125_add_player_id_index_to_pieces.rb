class AddPlayerIdIndexToPieces < ActiveRecord::Migration
  def change
    add_index :pieces, :player_id
  end
end
