module TimeArray


  class Compact
    attr_reader :v, :unit
    def initialize(v, unit)
      @v    = v
      @unit = unit
    end
    alias :values :v
    alias :array :v
    
  end

  class Unit
    ETERNITY = 4
    YEAR     = 3
    MONTH    = 2
    DAY      = 1
    HOUR     = 0
    
    def self.name(num)
      case num
      when ETERNITY
        :eternity
      when YEAR
        :year
      when MONTH
        :month
      when DAY
        :day
      else
        :hour
      end
    end
  end
end
