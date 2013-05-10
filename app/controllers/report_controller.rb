class ReportController < ApplicationController
	# GET /report
	def index
		@reports = Report.paginate( :page => params[:page], :per_page => 15 )
		respond_to do |format|
			format.html
		end
	end

	# GET /report/1
	def show
		@report = Report.find(params[:id])
		@mi = @report.cell.module_instances

		respond_to do |format|
			format.html
			format.pdf {
				render 	:pdf => "#{@report.created_at.strftime("%Y-%m-%d")}_report#{@report.id}_cell#{@report.cell.id}",
						:layout => "pdf.html.erb",
						:template => "report/show.html.erb",
						:disable_internal_links => true,
						:disable_external_links => true
			}
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
