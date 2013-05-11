class ReportsController < ApplicationController

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
		
		respond_to do |format|
			format.html # new.html.erb
			format.json { render json: @report }
		end
	end
	
	# POST /reports
	# POST /reports.json
	def create
		@report = Report.create(params[:report])
		
		respond_to do |format|
			if @report.save
				format.html { redirect_to @report, notice: 'Report was successfully created.' }
				format.json { render json: @report, status: :created, location: @report }
			else
				format.html { render action: "new" }
				format.json { render json: @report.errors, status: :unprocessable_entity }
			end
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
