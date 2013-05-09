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

	def delete
	end
end
