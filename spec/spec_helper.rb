require 'coveralls'
Coveralls.wear!

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.filter_run_including focus: true
  config.run_all_when_everything_filtered = true
end
