class HookController < ApplicationController
	
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
		end
	end
end
