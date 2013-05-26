require 'rubygems'
require 'test_helper'
require 'selenium-webdriver'


class CellsViewTests < Test::Unit::TestCase
		attr_reader :browser

	def setup
		driver = Selenium::WebDriver.for :firefox
		wait = Selenium::WebDriver::Wait.new :timeout => 10
		@driver.navigate.to "http://life.jstfy.com/cells"
	end

	def teardwown
		driver.quit
	end
end