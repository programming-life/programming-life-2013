class AddStepToModuleTemplate < ActiveRecord::Migration
  def change
    add_column :module_templates, :step, :text
  end
end
