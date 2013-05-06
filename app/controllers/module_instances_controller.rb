class ModuleInstancesController < ApplicationController
  # GET /module_instances
  # GET /module_instances.json
  def index
    @module_instances = ModuleInstance.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @module_instances }
    end
  end

  # GET /module_instances/1
  # GET /module_instances/1.json
  def show
    @module_instance = ModuleInstance.find(params[:id])

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
	@module_instance.build_module_values
	@module_instance.build_module_parameters

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @module_instance }
    end
  end

  # GET /module_instances/1/edit
  def edit
    @module_instance = ModuleInstance.find(params[:id])
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
      if @module_instance.update_attributes(params[:module_instance])
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
end
