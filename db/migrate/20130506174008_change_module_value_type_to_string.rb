class ChangeModuleValueTypeToString < ActiveRecord::Migration
	def up
		change_column :module_values, :value, :string
	end
	
	def down
		change_column :module_values, :value, :float
	end
end
