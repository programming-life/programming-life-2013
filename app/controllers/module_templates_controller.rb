class ModuleTemplatesController < ApplicationController
  # GET /module_templates
  # GET /module_templates.json
  def index
    @module_templates = ModuleTemplate.all
	
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @module_templates }
    end
  end

  # GET /module_templates/1
  # GET /module_templates/1.json
  def show
    @module_template = ModuleTemplate.find( params[:id] )
	@module_instances = ModuleInstance.where( :module_template_id => @module_template.id )
	@module_instances_page = @module_instances.paginate( :page => params[:page], :per_page => 20 )
	@module_parameters = ModuleParameter.where( :module_template_id => @module_template.id )

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @module_template }
    end
  end

  # GET /module_templates/new
  # GET /module_templates/new.json
  def new
    @module_template = ModuleTemplate.new
	@module_template.module_parameters.build
	@module_template.module_instances.build
	
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @module_template }
    end
  end

  # GET /module_templates/1/edit
  def edit
    @module_template = ModuleTemplate.find(params[:id])
  end

  # POST /module_templates
  # POST /module_templates.json
  def create
    @module_template = ModuleTemplate.new(params[:module_template])

    respond_to do |format|
      if @module_template.save
        format.html { redirect_to @module_template, notice: 'Module template was successfully created.' }
        format.json { render json: @module_template, status: :created, location: @module_template }
      else
        format.html { render action: "new" }
        format.json { render json: @module_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /module_templates/1
  # PUT /module_templates/1.json
  def update
    @module_template = ModuleTemplate.find(params[:id])

    respond_to do |format|
      if @module_template.update_attributes(params[:module_template])
        format.html { redirect_to @module_template, notice: 'Module template was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @module_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /module_templates/1
  # DELETE /module_templates/1.json
  def destroy
    @module_template = ModuleTemplate.find(params[:id])
    @module_template.destroy

    respond_to do |format|
      format.html { redirect_to module_templates_url }
      format.json { head :no_content }
    end
  end
end
