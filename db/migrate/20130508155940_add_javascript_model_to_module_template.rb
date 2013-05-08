class AddJavascriptModelToModuleTemplate < ActiveRecord::Migration
	def change
		add_column :module_templates, :javascript_model, :string
	end
end
