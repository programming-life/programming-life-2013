class GreetingsController < ApplicationController
  def index
	@message = "No greetings today."
  end

  def hello
	@message = "Hello " + ( params['name'] || "you!" )
  end
end
