require 'bundler/setup'
require 'cryptcheck/engine'

require 'awesome_print'
require 'colorize'
require 'pry-byebug'
require 'simplecov'
SimpleCov.start do
	add_filter 'spec/'
end

require './spec/helpers'
RSpec.configure do |c|
	c.include Helpers
end

RSpec.configure do |config|
	# Enable flags like --only-failures and --next-failure
	config.example_status_persistence_file_path = '.rspec_status'

	# Disable RSpec exposing methods globally on `Module` and `main`
	config.disable_monkey_patching!

	config.expect_with :rspec do |c|
		c.syntax = :expect
	end
end