class AddNameToModuleInstance < ActiveRecord::Migration
	def change
		add_column :module_instances, :name, :string
	end
end
