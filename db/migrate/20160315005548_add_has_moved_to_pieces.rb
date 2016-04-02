class AddHasMovedToPieces < ActiveRecord::Migration
  def change
    add_column :pieces, :has_moved?, :boolean, default: false
  end
end
