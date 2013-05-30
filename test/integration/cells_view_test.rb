require 'rubygems'
require 'test_helper'
require 'selenium-webdriver'


class CellsViewTests < ActionDispatch::IntegrationTest

	setup do
		@driver = Selenium::WebDriver.for :firefox
		@wait = Selenium::WebDriver::Wait.new :timeout => 10
		@driver.navigate.to "http://life.jstfy.com/cells"
	end

	teardown do
		@driver.quit
	end

	test "navigate to new-cell view" do 
		button = @driver.find_element(:class, "icon-plus-sign")
		button.click
		url = @driver.current_url
		assert_equal url, "http://life.jstfy.com/cells/new"
	end

	# test "navigate to show-view" do
	# 	button = @driver.find_element(:class, "icon-search")
	# 	button.click
	# 	url = @driver.current_url
	# 	assert_equal url, "http://life.jstfy.com/cells/" + 
	# end

	# test "navigate to edit view" do 
	# 	button = @driver.find_element(:class, "icon-pencil")
	# 	button.click
	# 	url = @driver.current_url
	# 	assert_equal url, "http://life.jstfy.com/cells/1/edit"
	# end

	# test "navigate to generate-report view" do 
	# 	button = @driver.find_element(:class, "icon-list-alt")
	# 	button.click
	# 	url = @driver.current_url
	# 	assert_equal url, "http://life.jstfy.com/reports/new"
	# end

end