class HookController < ApplicationController
	
	def index
		@version = `git describe --abbrev=0`
	end

	def post
		# TODO check if this is really from Travis CI
		# Check if the branch name is master
		# Check if it built correctly
		
		`cd /var/www/life/`
		`git checkout master`
		`git reset --hard HEAD`
		@exitcode = `git pull origin master`
		@version = `git describe --abbrev=0`
	end
end
