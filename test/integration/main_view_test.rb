require 'test_helper'
require 'selenium-webdriver'



class MainViewTest < ActionDispatch::IntegrationTest

	setup do
		# caps = Selenium::WebDriver::Remote::Capabilities.firefox
		# caps.platform = "Windows 7"
		# caps.version = "21"
		# caps[:name] = "Testing Selenium with Ruby on Sauce"
		@driver = Selenium::WebDriver.for :firefox
		 # = Selenium::WebDriver.for(
			# :remote,
			# :url => "http://vincentrobbemond:d59ae46b-e2a3-49fa-9301-75528e09aa46@ondemand.saucelabs.com:80/wd/hub",
			# :desired_capabilities => caps
			# )
		@wait = Selenium::WebDriver::Wait.new :timeout => 10

		# navigate to the main view
		@driver.navigate.to "http://life.jstfy.com"
	end

	teardown do
		@driver.quit
	end

	#Mouseover event on class module-hitbox
	#Check if popover showed up on mouseover
	test "module mouseover" do
		#el = @driver.find_element(:class, "cellgrowth-hitbox")
		#@driver.mouse.move_to(el)
		#pop = @driver.find_element(:class, "cellgrowth-box")
		#assert pop.displayed?
	end

	#Click on module
	#Check if edit popover showed up
	test "open edit popover" do
		el = @driver.find_element(:class, "module-hitbox")
		el.click
		pop = @driver.find_element(:class, "popover")
		assert pop.displayed?
	end

	#Click on dummy module
	#Check wether a module has been added
	test "add a module" do
		el = @driver.find_element(:class, "inactive")
		el.click
		newmodule = @driver.find_element(:class, "module-hitbox")
		assert newmodule.displayed?
	end

	#Click on Action History Pane
	#Check if pane showed up
	test "view the actionhistory pane" do
		el = @driver.find_element(:class, "pane-button")
		el.click
		pane = @driver.find_element(:class, "pane-left")
		assert_equal pane.attribute("class"), "pane pane-left extended"
	end

end