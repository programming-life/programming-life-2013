require 'rubygems'
require 'test_helper'
require 'selenium-webdriver'


class ReportsViewTests < ActionDispatch::IntegrationTest

	def setup
		driver = Selenium::WebDriver.for :firefox
		wait = Selenium::WebDriver::Wait.new :timeout => 10
		@driver.navigate.to "http://life.jstfy.com/reports"
	end

	def teardwown
		driver.quit
	end
end