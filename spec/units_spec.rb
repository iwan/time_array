require 'spec_helper'

RSpec.describe 'units' do
  include TimeArray::Units


  it 'check if unit is valid' do
    expect(TimeArray::Units.valid?(:hour)).to be true
    expect(TimeArray::Units.valid?("hour")).to be true
    expect(TimeArray::Units.valid?(:day)).to be true
    expect(TimeArray::Units.valid?("day")).to be true
    expect(TimeArray::Units.valid?(:month)).to be true
    expect(TimeArray::Units.valid?("month")).to be true
    expect(TimeArray::Units.valid?(:year)).to be true
    expect(TimeArray::Units.valid?("year")).to be true

    expect(TimeArray::Units.valid?(:years)).to be false
    expect(TimeArray::Units.valid?("years")).to be false
  end
end