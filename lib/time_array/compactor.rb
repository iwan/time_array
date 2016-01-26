module TimeArray


  class CompactorTime
    attr_reader :time
    def initialize(t)
      @time = t
      # @time = Time.new(t.year, t.month, t.day, t.hour, 0, 0)
    end
    
    def change(step=:hour)
      nxt = @time+1.send(step)
      [:year, :month, :day, :hour].each do |st|
        return st if nxt.send(st)!=@time.send(st)
      end
    end

    def increment(step=:hour)
      @time+1.send(step)
    end
    
    def increment!(step=:hour)
      @time = increment(step)
    end
  end


  class GreatestUnit
    H = {eternity: 5, year: 4, month: 3, day: 2, hour: 1}
    attr_reader :c

    def initialize(initial_interval=:eternity)
      @c = initial_interval
    end

    def set(interval)
      @c = interval if H[interval]<H[@c]
    end
    
    def smallest
      H.keys.last
    end
  end


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
