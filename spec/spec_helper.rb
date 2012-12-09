require 'rubygems'

ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'factory_girl'
require 'database_cleaner'

# Database cleaner
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

# Require support scripts
Dir["#{Rails.root}/spec/support/*rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.fixture_path = "#{Rails.root}/spec/fixtures"


  # Model specific configs


  # Controller specific configs
  config.include ControllerTestHelpers, :type => :controller


  # View specific configs


  # Helper specific configs


  # Request specific configs


  # Reset cookies and local storage before each request spec.
  config.before(:each, :type => :request) do
    DatabaseCleaner.clean
  end

  config.after(:each, :type => :request) do
  end



  # Allow focusing on individual specs with :focus
  config.treat_symbols_as_metadata_keys_with_true_values = true  
  config.filter_run :focus => true  
  config.run_all_when_everything_filtered = true  
end
