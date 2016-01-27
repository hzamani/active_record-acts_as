RSpec::Matchers.define :act_as do |actable|
  match do |actor|
    if actor.is_a?(ActiveRecord::Base)
      actor.class.acting_as?(actable)
    else
      actor.acting_as?(actable)
    end
  end
end

RSpec::Matchers.define :be_actable do
  match do |actable|
    if actable.is_a?(ActiveRecord::Base)
      actable.class.actable?
    else
      actable.actable?
    end
  end
end
