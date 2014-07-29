require 'active_record'
require 'active_record/acts_as'

class Model < ActiveRecord::Base
end

RSpec.describe ActiveRecord, "Model" do
  subject { Model }

  it { is_expected.to respond_to(:acts_as) }
  it { is_expected.to respond_to(:actable) }
  it { is_expected.to respond_to(:acting_as?) }

  describe "#acting_as?" do
    it "returns false with any arg" do
      expect(subject.acting_as?).to be false
      expect(subject.acting_as?(String)).to be false
      expect(subject.acting_as?(:product)).to be false
    end
  end
end
