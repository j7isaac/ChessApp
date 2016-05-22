class AddAllowsEnPassantCaptureToGames < ActiveRecord::Migration
  def change
    add_column :games, :allows_en_passant_capture?, :boolean
  end
end
