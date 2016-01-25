require 'models'
require 'rspec/acts_as_matchers'

RSpec.describe "Custom RSpec matchers" do
  it { expect(Product).to be_actable }

  it { expect(Pen).to act_as(:product) }
  it { expect(Pen).to act_as(Product) }
end
