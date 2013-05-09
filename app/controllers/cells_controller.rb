class CellsController < ApplicationController
	# GET /cells
	# GET /cells.json
	def index

		@filters = { }
		@filters[:template] = params[:template].to_i if params.has_key?(:template)

		@cells = Cell.paginate( :page => params[:page], :per_page => 15 )

		if ( !@filters[:template].nil? )
			cells = ModuleInstance
				.where( :module_template_id => @filters[:template] )
				.select( :cell_id )
			@cells = @cells.where( :id => cells )
		end

		respond_to do |format|
			format.html # index.html.erb
			format.json { render json: @cells }
		end
	end

	# GET /cells/1
	# GET /cells/1.json
	def show
		@cell = Cell.find(params[:id])
		@module_instances = ModuleInstance.where( :cell_id => @cell.id )

		respond_to do |format|
			if ( params.has_key?(:all) )
			
				modules = @module_instances.map do | i | 
					{ 	
						template: i.module_template,
						instance: i,
						parameters: 
							Hash[ ( i.module_parameters.map { |p| p.key } ).zip( 
								i.module_parameters.map { |p| 
										( found = ( i.module_values.select{ |v| v.module_parameter == p } ).first ).nil? ? nil : found.value
									} 
								)
							]
					}
				end
				all = { 
					cell: @cell,
					modules: modules
				}
				format.json { 
					render json: { 
						cell: @cell,
						modules: modules
					} 
				}
			else
				format.json { render json: @cell }
			end
			format.html # show.html.erb
		end
	end

	# GET /cells/new
	# GET /cells/new.json
	def new
		@cell = Cell.new

		@available_templates = ModuleTemplate.all

		respond_to do |format|
			format.html # new.html.erb
			format.json { render json: @cell }
		end
	end

	# GET /cells/1/edit
	def edit
		@cell = Cell.find(params[:id])
	end

	# POST /cells
	# POST /cells.json
	def create
		@cell = Cell.new(params[:cell])

		respond_to do |format|
			if @cell.save
				format.html { redirect_to @cell, notice: 'Cell was successfully created.' }
				format.json { render json: @cell, status: :created, location: @cell }
			else
				format.html { render action: "new" }
				format.json { render json: @cell.errors, status: :unprocessable_entity }
			end
		end
	end

	# PUT /cells/1
	# PUT /cells/1.json
	def update
		@cell = Cell.find(params[:id])

		respond_to do |format|
			if @cell.update_attributes(params[:cell])
				format.html { redirect_to @cell, notice: 'Cell was successfully updated.' }
				format.json { head :no_content }
			else
				format.html { render action: "edit" }
				format.json { render json: @cell.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /cells/1
	# DELETE /cells/1.json
	def destroy
		@cell = Cell.find(params[:id])
		@cell.destroy

		respond_to do |format|
			format.html { redirect_to cells_url }
			format.json { head :no_content }
		end
	end
end
