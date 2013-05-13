class AddFileToModuleTemplate < ActiveRecord::Migration
	def change
		add_column :module_templates, :file, :string
	end
end
