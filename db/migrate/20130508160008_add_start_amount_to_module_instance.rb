class AddStartAmountToModuleInstance < ActiveRecord::Migration
	def change
		add_column :module_instances, :amount, :float
	end
end
