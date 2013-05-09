class ChangeModuleValueTypeToString2 < ActiveRecord::Migration
	def change
		change_column :module_values, :value, :text
	end
end
