class AddForeignKeysModuleInstance < ActiveRecord::Migration
	def change
		add_column :module_instances, :module_template_id, :integer
		add_column :module_instances, :cell_id, :integer
	end
end
