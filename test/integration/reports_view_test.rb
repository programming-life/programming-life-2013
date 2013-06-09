require 'test_helper'
require 'selenium-webdriver'


class ReportsViewTests < ActionDispatch::IntegrationTest

	setup do
		@driver = Selenium::WebDriver.for :firefox
		@wait = Selenium::WebDriver::Wait.new :timeout => 10
		@driver.navigate.to "http://life.jstfy.com/reports"
	end

	teardown do
		@driver.quit
	end

	test "navigate to new-report view" do
		button = @wait.until { @driver.find_element(:class, "icon-plus-sign") }
		button.click
		url = @driver.current_url
		assert_equal url, "http://life.jstfy.com/reports/new"
	end

end