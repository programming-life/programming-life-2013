class AddNameToModuleTemplates < ActiveRecord::Migration
  def change
    add_column :module_templates, :name, :string
  end
end
