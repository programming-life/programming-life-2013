class CreateModuleParameters < ActiveRecord::Migration
  def change
    create_table :module_parameters do |t|
      t.integer :id
      t.string :key

      t.timestamps
    end
    add_index :module_parameters, :id, :unique => true
  end
end
