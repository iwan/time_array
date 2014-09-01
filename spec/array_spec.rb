require 'spec_helper'

RSpec.describe 'array' do
  subject(:a1) { [1,2,3].timed("2014") }

  it 'init hour array' do
    expect(a1).to be_an_instance_of(TimeArray::TimeArray)
  end
end