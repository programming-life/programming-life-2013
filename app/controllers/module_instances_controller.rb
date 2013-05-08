class ModuleInstancesController < ApplicationController
	# GET /module_instances
	# GET /module_instances.json
	def index

		# We are actually looking for the template
		return if redirect?( nil )
	
		@filters = { }
		@filters[:cell] = params[:cell].to_i if params.has_key?(:cell)
		@filters[:template] = params[:template].to_i if params.has_key?(:template)
		#get_filters( :cell, :template )

		@module_instances = ModuleInstance.paginate( :page => params[:page], :per_page => 15 )
		@module_instances = filter_on_key( @module_instances, :module_template_id, @filters[:template] ) if ( !@filters[:template].nil? )
		@module_instances = filter_on_key( @module_instances, :cell_id, @filters[:cell] ) if ( !@filters[:cell].nil? )

		respond_to do |format|
			format.html # index.html.erb
			format.json { render json: @module_instances }
		end
	end

	# GET /module_instances/1
	# GET /module_instances/1.json
	def show
	  
		# We need the following data
		#
		# Instance < Template
		# 	Template has Parameters
		# 	Instance has Values
		#
		@module_instance = ModuleInstance.find( params[:id] )

		@cell = @module_instance.cell
		@module_template = @module_instance.module_template
		
		return if redirect?( @module_template )
		
		# Gets the parameters and values and hashes them. Missing
		# values are substituted with nils, so the parameters will
		# show up.
		@module_parameters = @module_instance.module_parameters
		@module_values = @module_instance.module_values
		@module_hash = Hash[ ( @module_parameters.map { |p| p.key } ).zip( 
			@module_parameters.map { |p| 
					( found = ( @module_values.select{ |v| v.module_parameter == p } ).first ).nil? ? nil : found.value
				} 
			)
		]

		respond_to do |format|
			format.html # show.html.erb
			format.json { render json: @module_instance }
		end
	end

	# GET /module_instances/new
	# GET /module_instances/new.json
	def new

		@module_instance = ModuleInstance.new

		@module_instance.build_cell
		@module_instance.build_module_template
		@module_instance.module_values.build
		@module_instance.module_parameters.build

		respond_to do |format|
			format.html # new.html.erb
			format.json { render json: @module_instance }
		end
	end

	# GET /module_instances/1/edit
	def edit
		@module_instance = ModuleInstance.find(params[:id])

		@module_parameters = @module_instance.module_parameters
		@module_values = @module_instance.module_values
		@module_hash = Hash[ ( @module_parameters.map { |p| p.key } ).zip( 
			@module_parameters.map { |p| 
					( found = ( @module_values.select{ |v| v.module_parameter == p } ).first ).nil? ? nil : found.value
				} 
			)
		]
	end

	# POST /module_instances
	# POST /module_instances.json
	def create
		@module_instance = ModuleInstance.new(params[:module_instance])

		respond_to do |format|
			if @module_instance.save
				format.html { redirect_to @module_instance, notice: 'Module instance was successfully created.' }
				format.json { render json: @module_instance, status: :created, location: @module_instance }
			else
				format.html { render action: "new" }
				format.json { render json: @module_instance.errors, status: :unprocessable_entity }
			end
		end
	end

	# PUT /module_instances/1
	# PUT /module_instances/1.json
	def update
		@module_instance = ModuleInstance.find(params[:id])

		respond_to do |format|
		
			if params.has_key?( :module_parameters )
				parameter_update( params[:module_parameters] )
				format.json { render json: params[:module_parameters] }
			elsif @module_instance.update_attributes(params[:module_instance])
				format.html { redirect_to @module_instance, notice: 'Module instance was successfully updated.' }
				format.json { head :no_content }
			else
				format.html { render action: "edit" }
				format.json { render json: @module_instance.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /module_instances/1
	# DELETE /module_instances/1.json
	def destroy
		@module_instance = ModuleInstance.find(params[:id])
		@module_instance.destroy

		respond_to do |format|
			format.html { redirect_to module_instances_url }
			format.json { head :no_content }
		end
	end
 
	# GET /module_instances.json?redirect=template
	# GET /module_instances/1.json?redirect=template
	def redirect?( module_template )
		if params[:redirect] == 'template'
		
			# This is an existing instance
			if ( module_template )
				respond_to do |format|
					format.json { redirect_to module_template_path( module_template, :format => 'json' ), :status => :found }
				end
				return true
				
			# This is a new instance (maybe existing template)
			else
				type = params.has_key?(:type) ? params[:type] : ''
				module_template = ModuleTemplate.where( :javascript_model => type ).first
				respond_to do |format|
					if ( module_template )
						format.json { redirect_to module_template_path( module_template, :format => 'json' ), :status => :found }
					else
						format.json { head :no_content } 
					end
				end
				return true
			end
			
		end
		return false
	end
	
	# Tries to update the parameters
	#
	
	def parameter_update( parameters )
	
		@module_instance.module_parameters
			.each do |p|
				updated_parameter = nil
				parameters.each do |i,u| 
					updated_parameter = u if u[:key] == p.key
				end
				
				if ( !updated_parameter.nil? )
					current_parameter = ( @module_instance.module_values.select{ |v| v.module_parameter == p } ).first
					if ( current_parameter.nil? )
						value = ModuleValue.create( {
							module_instance_id: @module_instance.id, 
							module_parameter_id: p.id,
							value: updated_parameter[:value].to_json
						})
						value.save
					else
						current_parameter.update_attributes( { value: updated_parameter[:value].to_json } )
					end
				end
			end
	end
end
