class AddForeignKeysModuleValue < ActiveRecord::Migration
  	def change
		add_column :module_values, :module_parameter_id, :integer
		add_column :module_values, :module_instance_id, :integer
	end
end
