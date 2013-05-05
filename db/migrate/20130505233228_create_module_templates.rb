class CreateModuleTemplates < ActiveRecord::Migration
  def change
    create_table :module_templates do |t|

      t.timestamps
    end
  end
end
