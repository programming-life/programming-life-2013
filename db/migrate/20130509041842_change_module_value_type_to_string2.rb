class ChangeModuleValueTypeToString2 < ActiveRecord::Migration
	def up
		change_column :module_values, :value, :text
	end
	
	def down
		change_column :module_values, :value, :string
	end
end
