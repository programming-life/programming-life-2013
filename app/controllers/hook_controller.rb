class HookController < ApplicationController	
	before_filter :set_cache_buster
	
	def index
		@version = `git describe`
		@branch = `git rev-parse --abbrev-ref HEAD`
	end

	def post
		@host  = `host #{request.remote_ip}`
		@branch = params[:branch]
		@status = params[:status_message]

		if (
			@host.include? "amazonaws.com" and
			@branch == "master" and 
			@status == "Passed"
		)
			@command = "cd /var/www/life/ && " +
			"git fetch --tags && " + 
			"git checkout master && " +
			"git reset --hard HEAD && " + 
			"git pull origin master"

			`#{@command}`
			@exitcode = $?.exitstatus
			@version = `git describe --abbrev=0`
			
			`bundle install --deployment`
			`rake db:migrate`
		end
	end
	
	def version
		respond_to do | format |
			format.json { render json: { major: 1, minor: 5, revision: 6, full: '1.5.6' } }
		end
	end

	def set_cache_buster
		response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
		response.headers["Pragma"] = "no-cache"
		response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
	end
end
