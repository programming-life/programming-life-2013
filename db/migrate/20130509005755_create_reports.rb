class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer :id
      t.integer :cell_id

      t.timestamps
    end
    add_index :reports, :id, :unique => true
  end
end
