require "rubygems"
require "yaml"

require "rspec/autorun"

# Load the base context for acceptance tests
require "support/acceptance_context"

# Load our test configuration
spec_config_file = File.expand_path("../../config.yml", __FILE__)
raise "A config.yml must be present in the spec directory." if !File.file?(spec_config_file)
$spec_config = YAML.load_file(spec_config_file.to_s)

# Configure RSpec
RSpec.configure do |c|
  c.expect_with :rspec
end
