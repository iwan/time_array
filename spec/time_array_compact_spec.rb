require 'spec_helper'
require 'active_support/core_ext/time/zones'

RSpec.describe 'compactor' do
  subject(:year) { "2013" }
  subject(:y_arr) { [3.14] }
  subject(:m_arr) { (1..12).to_a.map{|e| e%2==0 ? 1.2 : 2.98} }
  subject(:d_arr) { (1..365).to_a.map{|e| e%2==0 ? 1.2 : 2.98} }
  subject(:h_arr) { (1..8760).to_a.map{|e| e%2==0 ? 1.2 : 2.98} }

  def build_array(year, step)
    Time.zone = "Rome"
    t0 = Time.zone.parse("#{year}-01-01")
    t1 = t0+1.year
    size = (t1-t0)/3600
    Array.new(size){|i| (t0+i.hours).send(step) }
  end

  context 'initial unit is hour' do
    it "compact month to hour" do
      arr = build_array(2013, :month)
      ta = TimeArray::TimeArray.new(year, arr)
      expect(ta.greatest_unit).to eq(:month)

      arr[2] = -1.0    # dirty, degrade to :hour
      ta = TimeArray::TimeArray.new(year, arr)
      expect(ta.greatest_unit).to eq(:hour)
    end

    it "compact day to hour" do
      arr = build_array(2013, :day)
      ta = TimeArray::TimeArray.new(year, arr)
      expect(ta.greatest_unit).to eq(:day)

      arr[2] = -1.0 # dirty, degrade to :hour
      ta = TimeArray::TimeArray.new(year, arr)
      expect(ta.greatest_unit).to eq(:hour)
    end

    it "cannot compact" do
      ta = TimeArray::TimeArray.new(year, h_arr)
      expect(ta.greatest_unit).to eq(:hour)
    end
  end

  context 'initial unit is not hour' do

    it "compact to year" do
      ta = TimeArray::TimeArray.new(year, y_arr, unit: :year)
      expect(ta.greatest_unit).to eq(:year)

      arr = Array.new(8760, 4.1)
      ta = TimeArray::TimeArray.new(year, arr)
    end

    it "compact to month" do
      ta = TimeArray::TimeArray.new(year, m_arr, unit: :month)
      st = ta.start_time.clone
      expect(ta.greatest_unit).to eq(:month)
      expect(ta.start_time).to eq(st)
    end

    it "compact to day" do
      ta = TimeArray::TimeArray.new(year, d_arr, unit: :day)
      expect(ta.greatest_unit).to eq(:day)
    end
  end


  context 'compact method' do
    it "compact to year" do
      ta = TimeArray::TimeArray.new(year, y_arr, unit: :year)
      compact = ta.compact
      expect(compact.unit).to eq(:year)
      expect(compact).to respond_to(:v)
      expect(compact).to respond_to(:values)
      expect(compact).to respond_to(:array)
      expect(compact.v).to eq(y_arr)
    end

    it "compact to month" do
      ta = TimeArray::TimeArray.new(year, m_arr, unit: :month)
      compact = ta.compact
      expect(compact.unit).to eq(:month)
      expect(compact.v).to eq(m_arr)
    end

    it "compact to day" do
      ta = TimeArray::TimeArray.new(year, d_arr, unit: :day)
      compact = ta.compact
      expect(compact.unit).to eq(:day)
      expect(compact.v).to eq(d_arr)
    end

    it "compact to hour" do
      ta = TimeArray::TimeArray.new(year, h_arr, unit: :hour)
      compact = ta.compact
      expect(compact.unit).to eq(:hour)
      expect(compact.v).to eq(h_arr)
    end
  end
end