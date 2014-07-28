require 'models'

RSpec.describe "ActiveRecord::Base model with #acts_as called" do
  subject { Pen }

  it "has a has_one relation" do
    association = subject.reflect_on_all_associations.find { |r| r.name == :product }
    expect(association).to_not be_nil
    expect(association.macro).to eq(:has_one)
    expect(association.options).to have_key(:as)
  end
end
