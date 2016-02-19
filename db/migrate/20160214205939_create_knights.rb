class CreateKnights < ActiveRecord::Migration
  def change
    create_table :knights do |t|

      t.timestamps
    end
  end
end
