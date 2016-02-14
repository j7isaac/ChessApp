class CreateQueens < ActiveRecord::Migration
  def change
    create_table :queens do |t|

      t.timestamps
    end
  end
end
