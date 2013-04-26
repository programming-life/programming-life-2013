class HookController < ApplicationController
	def index
		`cd /var/www/life/`
		`git checkout master`
		`git reset --hard HEAD`
		`git pull origin master`
	end
end
