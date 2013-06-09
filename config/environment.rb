ENV['LD_LIBRARY_PATH'] = "#{ENV['LD_LIBRARY_PATH']}:/usr/local/lib"

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
ProgrammingLife::Application.initialize!
