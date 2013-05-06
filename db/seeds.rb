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
			name: 'ModuleA',
			file: 'lipid'
			#k, consume
		},
		
		{
			name: 'ModuleB',
			file: 'substrate'
			#k
		},
		
		{
			name: 'ModuleC',
			file: 'metabolism'
			#k, k_met
		},
		
		{
			name: 'ModuleD',
			file: nil
			#lipsum
		}
	]
)

parameters = ModuleParameter.create(
	[
		# parameter 0
		{ 
			key: 'k', 
			module_template_id: templates.at(0).id
			#ModuleA
		}, 
		
		# parameter 1
		{ 
			key: 'consume', 
			module_template_id: templates.at(0).id 
			#ModuleA
		},
		
		# parameter 2
		{ 
			key: 'k', 
			module_template_id: templates.at(1).id 
			#ModuleB
		}, 
		
		# parameter 3
		{ 
			key: 'k', 
			module_template_id: templates.at(2).id 
			#ModuleC
		},
		
		# parameter 4
		{ 
			key: 'k_met', 
			module_template_id: templates.at(2).id
			#ModuleC
		},
		
		# parameter 5
		{ 
			key: 'lipsum', 
			module_template_id: templates.at(3).id 
			#ModuleD
		}, 
		
		
	]
)

cells = Cell.create(
	[
		{ 
			name: 'CellA'
		},
		
		{ 
			name: 'CellB' 
		},
		
		{ 
			name: 'CellC' 
		} 
	]
)

instances = ModuleInstance.create(
	[
		# instance 0
		{ 
			module_template_id: templates.at(0).id , 
			cell_id: cells.at(0).id
			#CellA, #ModuleA
		}, 
		
		# instance 1
		{ 
			module_template_id: templates.at(1).id , 
			cell_id: cells.at(0).id
			#CellA, #ModuleB
		},
		
		# instance 2
		{ 
			module_template_id: templates.at(0).id , 
			cell_id: cells.at(1).id 
			#CellB, #ModuleA
		},
		
		# instance 3
		{ 
			module_template_id: templates.at(0).id , 
			cell_id: cells.at(2).id
			#CellC, #ModuleA
		},
		
		# instance 4
		{ 
			module_template_id: templates.at(2).id , 
			cell_id: cells.at(2).id 
			#CellC, #ModuleC
		},
		
		# instance 5
		{ 
			module_template_id: templates.at(3).id , 
			cell_id: cells.at(2).id 
			#CellD, #ModuleD
		}
	] 
)

ModuleValue.destroy_all()

values = ModuleValue.create(
	[
		# instance 0: Module A
		{ 
			value: 1, 
			module_parameter_id: parameters.at(0).id, #k
			module_instance_id: instances.at(0).id 
		}, 
		{ 
			value: 's_int', 
			module_parameter_id: parameters.at(1).id, #consume
			module_instance_id: instances.at(0).id 
		},
		
		# instance 1: Module B
		{ 
			value: 0.8, 
			module_parameter_id: parameters.at(2).id, #k
			module_instance_id: instances.at(1).id 
		}, 
		
		# instance 2: Module A
		{ 
			value: 0.5, 
			module_parameter_id: parameters.at(0).id, #k
			module_instance_id: instances.at(2).id 
		}, 
		{ 
			value: 's_int', 
			module_parameter_id: parameters.at(1).id, #consume
			module_instance_id: instances.at(2).id 
		},
		
		# instance 3: Module A
		{ 
			value: 1, 
			module_parameter_id: parameters.at(0).id, #k
			module_instance_id: instances.at(3).id 
		}, 
		{ 
			value: 'p_int', 
			module_parameter_id: parameters.at(1).id, #consume
			module_instance_id: instances.at(3).id 
		},
		
		# instance 4: Module C
		{ 
			value: 0.75, 
			module_parameter_id: parameters.at(3).id, #k
			module_instance_id: instances.at(4).id 
		},
		
		{ 
			value: 0.2, 
			module_parameter_id: parameters.at(4).id, #k_met
			module_instance_id: instances.at(4).id 
		},
		
		# instance 5: Module D
		{ 
			value: 'dolor', 
			module_parameter_id: parameters.at(5).id, #k
			module_instance_id: instances.at(5).id 
		},
	]
)