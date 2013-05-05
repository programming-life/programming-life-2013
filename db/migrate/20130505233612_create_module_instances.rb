class CreateModuleInstances < ActiveRecord::Migration
  def change
    create_table :module_instances do |t|
	  t.integer :id
      t.timestamps
    end
	add_index :module_instances, :id, :unique => true
  end
end
