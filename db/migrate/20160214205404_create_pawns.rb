class CreatePawns < ActiveRecord::Migration
  def change
    create_table :pawns do |t|

      t.timestamps
    end
  end
end
