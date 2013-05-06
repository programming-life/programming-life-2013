class CreateModuleValues < ActiveRecord::Migration
  def change
    create_table :module_values do |t|
      t.float :value

      t.timestamps
    end
  end
end
