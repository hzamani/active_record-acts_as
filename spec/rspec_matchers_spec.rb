require 'models'
require 'active_record/acts_as/matchers'

RSpec.describe "Custom RSpec matchers" do
  it { expect(Product).to be_actable }
  it { expect(Product.new).to be_actable }

  it { expect(Pen).to act_as(:product) }
  it { expect(Pen).to act_as(Product) }
  it { expect(Pen.new).to act_as(:product) }
  it { expect(Pen.new).to act_as(Product) }
end
