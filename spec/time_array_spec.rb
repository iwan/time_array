require 'spec_helper'

RSpec.describe 'time array' do
  subject(:a1) { TimeArray::TimeArray.new("2013", [1,2,3], zone: "Rome", unit: :hour) }
  values = [1,2,3]


  it 'init' do
    expect(a1).to be_an_instance_of(TimeArray::TimeArray)
  end

  it 'unit option on initialize' do
    expect(TimeArray::TimeArray.new("2013", [1,2,3], unit: :hour).unit).to eq(:hour)
    expect(TimeArray::TimeArray.new("2013", [1,2,3], zone: "Rome", unit: :hour).unit).to eq(:hour)
    expect(TimeArray::TimeArray.new("2013", [1,2,3], unit: 'hour').unit).to eq(:hour)
    expect(TimeArray::TimeArray.new("2013").unit).to eq(:hour)

    expect(TimeArray::TimeArray.new("2013", [1,2,3], unit: 'month').unit).to eq(:month)
    expect(TimeArray::TimeArray.new("2013", [1,2,3], unit: 'year').unit).to eq(:year)
    expect(TimeArray::TimeArray.new("2013", [1,2,3], unit: 'day').unit).to eq(:day)

    expect{ TimeArray::TimeArray.new("2013", [1,2,3], unit: 'foo').unit}.to raise_error(ArgumentError)
  end

  it 'zone opt on initialize' do
    expect(a1.zone).to eq("Rome")
    expect(TimeArray::TimeArray.new("2013", [1,2,3]).zone).to eq("Rome")
    expect(TimeArray::TimeArray.new("2013", [1,2,3], zone: "London").zone).to eq("London")
    expect(a1.time_zone).to be_an_instance_of(ActiveSupport::TimeZone)
  end

  it 'start_time on initialize' do
    expect(TimeArray::TimeArray.new("2013", [1,2,3], zone: "Rome").start_time.to_s).to eq("2013-01-01 00:00:00 +0100")
    expect(TimeArray::TimeArray.new("2013-03-04", [1,2,3], zone: "Rome").start_time.to_s).to eq("2013-03-04 00:00:00 +0100")
    expect(TimeArray::TimeArray.new("2013-03-04 13", [1,2,3], zone: "Rome").start_time.to_s).to eq("2013-03-04 13:00:00 +0100")
  end

  it 'clone' do
    orig = TimeArray::TimeArray.new("2013", [1,2,3], zone: "Rome")
    cloned = orig.clone
    expect(orig.start_time).to equal(orig.start_time)
    expect(cloned.start_time).not_to equal(orig.start_time)
    expect(cloned.v).not_to equal(orig.v)
    # expect(cloned.time_zone).not_to equal(orig.time_zone) # why?
    
  end
end