class CreateCells < ActiveRecord::Migration
  def change
    create_table :cells do |t|
      t.string :name
      t.integer :id

      t.timestamps
    end
    add_index :cells, :id, :unique => true
  end
end
