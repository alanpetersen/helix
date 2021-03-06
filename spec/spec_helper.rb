require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |config|

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

end
