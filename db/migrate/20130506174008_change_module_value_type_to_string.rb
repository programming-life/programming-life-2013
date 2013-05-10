class ChangeModuleValueTypeToString < ActiveRecord::Migration
	def change
		change_column :module_values, :value, :string
	end
end
