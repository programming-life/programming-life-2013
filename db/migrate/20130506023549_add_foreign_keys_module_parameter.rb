class AddForeignKeysModuleParameter < ActiveRecord::Migration
	def change
		add_column :module_parameters, :module_template_id, :integer
	end
end
