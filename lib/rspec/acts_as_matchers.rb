RSpec::Matchers.define :act_as do |actable|
  match { |actor| actor.acting_as?(actable) }
end

RSpec::Matchers.define :be_actable do
  match { |klass| klass.actable? }
end
