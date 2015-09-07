require 'spec_helper'

RSpec.describe 'operations' do
  subject(:a1) { TimeArray::TimeArray.new("2013", [2.1], unit: :year) }
  subject(:a2) { TimeArray::TimeArray.new("2013", [3.7], unit: :year) }

  it 'sum time arrays' do
    b = a1+a2
    expect(b.size).to eq(8760)
    expect(b.sum).to be_within(0.001).of(8760*(2.1+3.7))

    c = a1+2
    expect(c.size).to eq(8760)
    expect(c.sum).to be_within(0.001).of(8760*(2.1+2))
  end

  it 'subtract time arrays' do
    b = a1-a2
    expect(b.size).to eq(8760)
    expect(b.sum).to be_within(0.001).of(8760*(2.1-3.7))

    c = a1-2
    expect(c.size).to eq(8760)
    expect(c.sum).to be_within(0.001).of(8760*(2.1-2))
  end

  it 'multiply time arrays' do
    b = a1*a2
    expect(b.size).to eq(8760)
    expect(b.sum).to be_within(0.001).of(8760*(2.1*3.7))

    c = a1*2
    expect(c.size).to eq(8760)
    expect(c.sum).to be_within(0.001).of(8760*(2.1*2))
  end

  it 'divide time arrays' do
    b = a1/a2
    expect(b.size).to eq(8760)
    expect(b.sum).to be_within(0.001).of(8760*(2.1/3.7))

    c = a1/2
    expect(c.size).to eq(8760)
    expect(c.sum).to be_within(0.001).of(8760*(2.1/2))
  end

  it 'divide time arrays by zero' do
    a3 = TimeArray::TimeArray.new("2013", [1,0,1,1,1,1,1,1,1,1,1,1], unit: :month)
    c = a1/a3
    expect(c.size).to eq(8760)
    expect(c.sum).to eq(Float::INFINITY)
  end

  it "sum month values" do
    year = 2013
    b = TimeArray::TimeArray.new(year.to_s, [1], unit: :year)
    b = b.month_sum
    h = {}
    Time.zone = "Rome"
    12.times do |m|
      t1 = Time.zone.parse("#{year}-#{m+1}-01 00:00")
      t2 = t1+1.month
      t3 = (t2-t1)/3600
      hours = t3.to_i
      h[m+1] = hours
    end
    h.each_pair do |month, count|
      expect(b.value_at(year,month,1,0)).to eq(count)
    end
  end

  describe "#value_at" do
    context 'date as datetime' do
      context 'correct date' do
        it "return the correct first value" do
          Time.zone = "Rome"
          dt = Time.zone.parse("2013-01-01 00:00")
          expect(a1.value_at(dt)).to eq(2.1)
        end
        it "return the correct last value" do
          Time.zone = "Rome"
          dt = Time.zone.parse("2013-12-31 23:00")
          expect(a1.value_at(dt)).to eq(2.1)
        end
        it "return the correct inner value" do
          Time.zone = "Rome"
          dt = Time.zone.parse("2013-05-21 05:00")
          expect(a1.value_at(dt)).to eq(2.1)
        end
      end
      context 'date not correct' do
        it "raise error with a date before" do
          Time.zone = "Rome"
          dt = Time.zone.parse("2012-12-31 23:00")
          expect{ a1.value_at(dt)}.to raise_error(RuntimeError)
        end
        it "raise error with a date after" do
          Time.zone = "Rome"
          dt = Time.zone.parse("2014-01-01 00:00")
          expect{ a1.value_at(dt)}.to raise_error(RuntimeError)
        end
      end
      
    end

    context 'date as numbers' do
      context 'correct date' do
        it "return the correct first value" do
          expect(a1.value_at(2013,1,1,0)).to eq(2.1)
        end
        it "return the correct last value" do
          expect(a1.value_at(2013,12,31,23)).to eq(2.1)
        end
        it "return the correct inner value" do
          expect(a1.value_at(2013,5,21,5)).to eq(2.1)
        end
      end
      context 'date not correct' do
        it "raise error with a date before" do
          expect{ a1.value_at(2012,12,31,23)}.to raise_error(RuntimeError)
        end
        it "raise error with a date after" do
          expect{ a1.value_at(2014,1,1,0)}.to raise_error(RuntimeError)
        end
      end

    end

    it "#month_count" do
      a = a1.month_count
      expect(a.value(0)).to eq(24*31)
      expect(a.value(1)).to eq(24*31)
      expect(a.value(24*31)).to eq(24*28)
      expect(a.value(24*31+24*28)).to eq(24*31-1) # because of daylight saving time
      expect(a.value(a.size-1)).to eq(24*31)
    end

    it '#execute' do
      b = a1.execute do |v|
        2 * v + 1
      end
      expect(b.value(0)).to eq(2*2.1+1)
      expect(b.value(1000)).to eq(2*2.1+1)
      expect(b.value(b.size-1)).to eq(2*2.1+1)
    end
  end
end