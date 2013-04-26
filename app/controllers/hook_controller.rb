class HookController < ApplicationController
	def index
		`'cd /var/www/life/ && git reset --hard HEAD && git pull`
	end
end
