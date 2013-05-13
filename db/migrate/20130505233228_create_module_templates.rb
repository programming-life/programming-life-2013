class CreateModuleTemplates < ActiveRecord::Migration
  def change
    create_table :module_templates do |t|
	  t.integer :id
      t.timestamps
    end
	add_index :module_templates, :id, :unique => true
  end
end
