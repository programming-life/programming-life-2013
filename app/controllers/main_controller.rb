class MainController < ApplicationController
	def index
		@controller = 'Controller.Main'
		@cell = Cell.new
	end
end
