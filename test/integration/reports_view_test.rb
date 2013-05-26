require 'rubygems'
require 'test_helper'
require 'selenium-webdriver'


class ReportsViewTests < ActionDispatch::IntegrationTest

	def setup
		@driver = Selenium::WebDriver.for :firefox
		@wait = Selenium::WebDriver::Wait.new :timeout => 10
		@driver.navigate.to "http://life.jstfy.com/reports"
	end

	test "navigate to show-reports view" do
		button = @driver.find_element(:class, "icon-search")
		button.click
		url = @driver.current_url
		assert_equal url, "http://life.jstfy.com/reports/1"
	end

	test "navigate to cell view" do
		link = @driver.find_element(:tag_name, "a")
		link.click
		url = @driver.current_url
		assert_equal url, "http://life.jstfy.com/cells/1"
	end

	test "navigate to new-report view" do
		button = @driver.find_element(:class, "icon-plus-sign")
		button.click
		url = @driver.current_url
		assert_equal url, "http://life.jstfy.com/reports/new"
	end

	def teardwown
		driver.quit
	end
end