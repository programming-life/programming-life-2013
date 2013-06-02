class RemoveModuleTemplateFromModuleTemplate < ActiveRecord::Migration
	def up
		#remove_column :module_templates, :module_template
	end

	def down
		add_column :module_templates, :module_template, :string
	end
end
