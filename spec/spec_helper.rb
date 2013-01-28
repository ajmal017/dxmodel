require 'rubygems'

ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'factory_girl'
require 'database_cleaner'
require 'ruby-debug'

# Require support scripts
Dir["#{Rails.root}/spec/support/*rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.fixture_path = "#{Rails.root}/spec/fixtures"

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # Allow focusing on individual specs with :focus
  config.treat_symbols_as_metadata_keys_with_true_values = true  
  config.filter_run :focus => true  
  config.run_all_when_everything_filtered = true  
end
