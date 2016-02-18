class CreateRooks < ActiveRecord::Migration
  def change
    create_table :rooks do |t|

      t.timestamps
    end
  end
end
