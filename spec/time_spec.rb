require 'spec_helper'

RSpec.describe 'time' do
  subject(:a1) { [1,2,3].timed("2014") }

  describe 'year_changed?' do
    it "is true" do
      expect(Time.new(2015,1,1,0,20).year_changed?).to be true
    end

    it "is false" do
      expect(Time.new(2015,1,1,1,0).year_changed?).to be false
      expect(Time.new(2015,1,2,0,20).year_changed?).to be false
      expect(Time.new(2015,2,1,0,20).year_changed?).to be false
    end
  end

  describe 'month_changed?' do
    it "is true" do
      expect(Time.new(2015,1,1,0,20).month_changed?).to be true
      expect(Time.new(2015,2,1,0,20).month_changed?).to be true
    end

    it "is false" do
      expect(Time.new(2015,1,1,1,0).month_changed?).to be false
      expect(Time.new(2015,1,2,0,20).month_changed?).to be false
    end
  end

  describe 'day_changed?' do
    it "is true" do
      expect(Time.new(2015,1,1,0,20).day_changed?).to be true
      expect(Time.new(2015,1,2,0,20).day_changed?).to be true
      expect(Time.new(2015,2,1,0,20).day_changed?).to be true
    end

    it "is false" do
      expect(Time.new(2015,1,1,1,0).day_changed?).to be false
    end
  end
end