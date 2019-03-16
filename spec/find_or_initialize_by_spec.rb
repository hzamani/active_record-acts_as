require 'models'

RSpec.describe 'Model Initialization' do
  subject { Pen }

  let(:pen_attributes) { { name: 'pen', color: 'red' } }

  before(:each) { clear_database }

  it 'find_or_initialize_by works' do
    pen = subject.find_or_initialize_by(pen_attributes)
    expect(pen.persisted?).to be false
    expect(pen.name).to eq(pen_attributes[:name])
    expect(pen.color).to eq(pen_attributes[:color])
  end

  it 'where.first_or_initialize works' do
    pen = subject.where(pen_attributes).first_or_initialize
    expect(pen.persisted?).to be false
    expect(pen.name).to eq(pen_attributes[:name])
    expect(pen.color).to eq(pen_attributes[:color])
  end
end
