require 'rubygems'
require 'test_helper'
require 'selenium-webdriver'



class MainViewTest < ActionDispatch::IntegrationTest



	setup do
		@driver = Selenium::WebDriver.for :firefox
		@wait = Selenium::WebDriver::Wait.new :timeout => 10

		# navigate to the main view
		host_name = url_for(:controller => 'main', :action => 'index', :only_path => false)
		@driver.navigate.to "http://life.jstfy.com"
	end

	teardown do
		@driver.quit
	end

	#Mouseover event on class module-hitbox
	#Check if popover showed up on mouseover
	test "module mouseover" do
		el = @driver.find_element(:class, "module-hitbox")
		@driver.mouse.move_to(el)
		pop = @driver.find_element(:class, "popover")
		assert pop.displayed?
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
		@wait.until { pane.attribute("style") == "left: 0px;" }
	end

end