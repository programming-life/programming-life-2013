class ReportsController < ApplicationController
	require 'csv'
	require 'json'

	# GET /reports
	def index
		@reports = Report.paginate( :page => params[:page], :per_page => 15 )
		respond_to do |format|
			format.html
			format.json { render json: @reports }
		end
	end

	# GET /reports/1
	# GET /reports/1.json
	def show
		@report = Report.find(params[:id])
		@module_instances = @report.cell.module_instances
		@isPDF = false
		@controller = 'Controller.Report'

		respond_to do |format|
			format.html
			format.json { render json: @report }
		end
	end

	# GET /reports/new
	# GET /reports/new.json
	def new
		@report = Report.new
		@report.build_cell
		@p = params[:test]
		
		respond_to do |format|
			format.html # new.html.erb
			format.json { render json: @report }
		end
	end
	
	# POST /reports
	# POST /reports.json
	def create
		@report = Report.create(params[:report])
		
		@existing = Report.where( :cell_id => params[:report][:cell_id] ).first
		if @existing
			respond_to do |format|
				format.html { redirect_to @existing, notice: 'Report already existed.' }
				format.json { render json: @existing, status: :ok }
			end
		else
			respond_to do |format|
				if @report.save
					format.html { redirect_to @report, notice: 'Report was successfully created.' }
					format.json { render json: @report, status: :created, location: @report }
				else
					format.html { render action: "new" }
					format.json { render json: { :errors => @report.errors, :data => @report }, status: :unprocessable_entity }
				end
			end
		end
	end

	# PUT /report/1
	def update
		@report = Report.find(params[:id])
		@module_instances = @report.cell.module_instances
		@report_params = params[:report]
		@isPDF = (params[:commit] == 'Create PDF')
		@isCSV = (params[:commit] == 'Export to CSV')

		if ( @isPDF )
			@graphs = JSON.parse(params[:report][:graph_data])
			respond_to do |format|
				format.html { 
					render	:pdf 					=> "#{@report.created_at.strftime("%Y-%m-%d")}_#{@report.id}_#{@report.cell.id}",
							:disable_internal_links		=> true,
							:disable_external_links		=> true,
							:show_as_html                   => false,
							:template					=> 'reports/show'
				}
			end	
		elsif ( params[:commit] == 'Export to CSV' )
			@datasets = JSON.parse( params[:report][:datasets] )
			@xValues = JSON.parse( params[:report][:xValues] )
			@yArrays = []
			@modules = []

			@datasets.each do |key, values|
				@modules.push(key)
				@yArrays.push(values.first.last)
			end
			
			csv_string = CSV.generate do |csv|
				csv << ["X"] + @modules
				@xValues.each do |x|
					@yValues = [x]
					@yArrays.each do |array|
						@yValues.push(array.shift)
					end
					csv << @yValues
				end
			end

			send_data csv_string,
					:type => 'text/csv; charset=iso-8859-1; header=present',
					:disposition => "attachment; filename=#{@report.created_at.strftime("%Y-%m-%d")}_#{@report.id}_#{@report.cell.id}.csv"
		end	
	end

	# DELETE /reports/1
	# DELETE /reports/1.json
	def destroy
		@report = Report.find(params[:id])
		@report.destroy
		
		respond_to do |format|
			format.html { redirect_to reports_url }
			format.json { head :no_content }
		end
	end
end
