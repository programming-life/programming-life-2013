class PdftestController < ApplicationController
	def test
		respond_to do |format|
			format.pdf {
				render 	:pdf => "my_pdf",
						:layout => "pdf.html.erb",
						:template => "pdftest/test.pdf.erb"
			}
			format.html
		end 
	end
end
