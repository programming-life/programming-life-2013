class CreateModuleInstances < ActiveRecord::Migration
  def change
    create_table :module_instances do |t|

      t.timestamps
    end
  end
end
