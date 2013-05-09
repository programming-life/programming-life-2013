class ReportController < ApplicationController
	# GET /report
	def index
		@reports = Report.paginate( :page => params[:page], :per_page => 15 )
		respond_to do |format|
			format.html
			format.pdf
			format.xml
		end
	end

	# GET /report/1
	def show
		@report = Report.find(params[:id])
		@mi = @report.cell.module_instances

		respond_to do |format|
			format.html
		end
	end

	def create
	end

	def destroy
		@report = Report.find(params[:id])
		@report.destroy
		
		respond_to do |format|
			format.html { redirect_to report_index_url }
		end
	end
end
