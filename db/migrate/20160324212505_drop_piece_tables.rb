class DropPieceTables < ActiveRecord::Migration
  def change
    drop_table :pawns
    drop_table :rooks
    drop_table :knights
    drop_table :bishops
    drop_table :kings
    drop_table :queens
  end
end
