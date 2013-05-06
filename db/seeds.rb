# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

templates = ModuleTemplate.create(
	[
		{ 
			name: 'ModuleA' 
		},
		
		{
			name: 'ModuleB' 
		}
	]
)

parameters = ModuleParameter.create(
	[
		{ 
			key: 'k', 
			module_template_id: templates.first.id 
		}, 
		
		{ 
			key: 'consume', 
			module_template_id: templates.first.id  
		}
	]
)

cells = Cell.create(
	[
		{ 
			name: 'CellA' 
		} 
	]
)

instances = ModuleInstance.create(
	[
		{ 
			module_template_id: templates.first.id , 
			cell_id: cells.first.id 
		}
	] 
)

values = ModuleValue.create(
	[
		{ 
			value: 1, 
			module_parameter_id: parameters.first.id, 
			module_instance_id: instances.first.id 
		}, 
		{ 
			value: 2, 
			module_parameter_id: parameters.last.id, 
			module_instance_id: instances.first.id 
		}
	]
)