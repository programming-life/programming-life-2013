# This file allows you to override various Teabag configuration directives when running from the command line. It is not
# required from within the Rails environment, so overriding directives that have been defined within the initializer
# is not possible.
#
# Set RAILS_ROOT and load the environment.
ENV["RAILS_ROOT"] = File.expand_path("../../", __FILE__)
require File.expand_path("../../config/environment", __FILE__)

# Provide default configuration.
#
# You can override various configuration directives defined here by using arguments with the teabag command.
#
# teabag --driver=selenium --suppress-log
# rake teabag DRIVER=selenium SUPPRESS_LOG=false
Teabag.setup do |config|
  # Driver / Server
  #config.driver           = "phantomjs" # available: phantomjs, selenium
  #config.server           = nil # defaults to Rack::Server

  # Behaviors
  #config.server_timeout   = 20 # timeout for starting the server
  #config.server_port      = nil # defaults to any open port unless specified
  #config.fail_fast        = true # abort after the first failing suite

  # Output
  #config.formatters       = "dot" # available: dot, tap, tap_y, swayze_or_oprah
  #config.suppress_log     = false # suppress logs coming from console[log/error/debug]
  #config.color            = true

  # Coverage (requires istanbul -- https://github.com/gotwarlost/istanbul)
  config.coverage         = true
  config.coverage_reports = "text,html,cobertura"
  config.suite do |suite|
	suite.no_coverage << %r{/spec/javascripts/*}
  end
  
  config.suite :models do |suite|
  	suite.matcher = "{spec/javascripts/model_specs/}/**/*_spec.{js,js.coffee,coffee}"
	suite.no_coverage << %r{/app/assets/javascripts/views/*}
	suite.no_coverage << %r{/app/assets/javascripts/controllers/*}
	suite.no_coverage << %r{/app/assets/javascripts/helpers/*}
  end
  
  config.suite :controllers do |suite|
  	suite.matcher = "{spec/javascripts/controller_specs/}/**/*_spec.{js,js.coffee,coffee}"
	suite.no_coverage << %r{/app/assets/javascripts/views/*}
	suite.no_coverage << %r{/app/assets/javascripts/models/*}
	suite.no_coverage << %r{/app/assets/javascripts/helpers/*}
  end

  config.suite :views do |suite|
  	suite.matcher = "{spec/javascripts/view_specs/}/**/*_spec.{js,js.coffee,coffee}"
	suite.no_coverage << %r{/app/assets/javascripts/controllers/*}
	suite.no_coverage << %r{/app/assets/javascripts/models/*}
	suite.no_coverage << %r{/app/assets/javascripts/helpers/*}
  end

  config.suite :helpers do |suite|
  	suite.matcher = "{spec/javascripts/helper_specs/}/**/*_spec.{js,js.coffee,coffee}"
	suite.no_coverage << %r{/app/assets/javascripts/views/*}
	suite.no_coverage << %r{/app/assets/javascripts/models/*}
	suite.no_coverage << %r{/app/assets/javascripts/controllers/*}
  end
end
