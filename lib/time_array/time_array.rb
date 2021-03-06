require 'active_support/core_ext/time/zones'
require 'active_support/core_ext/time/calculations'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/hash'

# require 'byebug'


module TimeArray
  class TimeArray
    attr_reader :start_time, :v, :unit

    # Used by each method
    class TimeAndValue
      attr_reader :time, :value
      def initialize(time, value)
        @time  = time
        @value = value
      end

      alias_method :datetime, :time
      alias_method :v, :value
    end

    def initialize(start_time, values=Vector.new, options={})
      manage_options options
      set_start_time start_time
      set_values     values      
    end


    def zone
      Time.zone.name
    end

    def time_zone
      Time.zone
    end

    def clone
      TimeArray.new(@start_time, (@v.clone rescue Vector.new), zone: Time.zone.name)
    end

    # Set array values to the given new value
    def all_to(new_value)
      @v = Vector.new(@v.size, new_value)
      self
    end

    def size
      @v.size
    end


    # get the sum of the values
    def sum(options = {})
      if options[:values]
        opt = options[:values].to_sym
        case opt
        when :positive, :non_negative
          @v.sum_positive
        when :negative, :non_positive
          @v.sum_negative
        when :zero
          0.0
        when :all, :non_zero
          @v.sum_all
        else
          raise ArgumentError, "Option '#{opt}' not recognized"
        end
      else
        @v.sum_all
      end
    end

    # alias :+ :sum

    # Count the values
    def count(options = {})
      if options[:values]
        raise ArgumentError, "Option not recognized" if !%w(positive negative non_positive non_negative non_zero zero all).include?(options[:values].to_s)
        @v.send("count_"+options[:values].to_s)
      else
        @v.count_all
      end
    end


    # Get the average of values
    def avg(options = {})
      c = count(options)
      return nil if c.zero? # if the array is empty will be returned nil
      sum(options) / c
    end

    # Get the minimum value
    def min
      @v.compact.min
    rescue
      nil
    end

    # Get the maximum value
    def max
      @v.compact.max
    rescue
      nil
    end

    # Round every values of the array
    def round!(ndigit=3)
      @v.collect!{|e| e.nil? ? nil : e.round(ndigit)}
      self
    end

    # def xy_array(options={}) # for the moment has been left out



    def empty?
      @v.nil? || @v.empty?
    end

    # Return the time assiociated with the last value
    def end_time
      return nil if empty?
      @start_time + (@v.size-1).hours
    end

    def clear_data
      raise NilStartTimeError if @start_time.nil?
      @v = Vector.new
      self
    end

    def aligned_with?(other_array)
      self.start_time==other_array.start_time && @v.size==other_array.size
    end

    def align_with(other_array)
      # @start_time    = other_array.start_time if @start_time.nil? # ====
      return self if empty?
      return clear_data if other_array.empty?
        
      
      new_start_time = [start_time, other_array.start_time].max
      new_end_time   = [end_time,   other_array.end_time].min

      if end_time.nil? || other_array.end_time.nil? || new_start_time>new_end_time
        clear_data
      else
        @v = @v[((new_start_time-start_time)/3600).to_i, 1+((new_end_time-new_start_time)/3600).to_i]
      end
      @start_time = new_start_time
      self      
    end


    def print_values
      start_time = @start_time - 1.hour
      @v.collect{|v| "#{(start_time+=1.hour).strftime('%Y-%m-%d %H:%M %a')}\t#{v}" }.join("\n")
    end

    def to_s
      "Start time: #{@start_time}\nData (size: #{@v.size}):\n#{print_values}"
    end

    # mah!
    def until_the_end_of_the_year(fill_value=0.0)
      t = Time.zone.parse("#{@start_time.year+1}-01-01")
      hh = (t-@start_time)/( 60 * 60) # final size
      @v += Vector.new(hh-@v.size, fill_value) if hh>@v.size
      self
    end

    def +(vec)
      oper(vec, :+)
    end

    def -(vec)
      oper(vec, :-)
    end

    def *(vec)
      oper(vec, :*)
    end

    def /(vec)
      oper(vec, :/)
    end

    def value(index)
      @v[index]
    end

    def first_values(number)
      @v[0,number]
    end

    def set_value(index, new_value)
      @v[index]=new_value if index>=0 && index<@v.size
    end

    def group_by(interval)
      raise ArgumentError, "interval not valid. Valid intervals are :hour, :day, :wday, :month, :year" unless Units.valid?(interval)
      t = start_time
      h = GroupHash.new{|h,k| h[k]=[]}
      @v.each do |v|
        h[t.send(interval)]<<v
        t+=1.hour
      end
      h
    end


    # Will return a Compact object, a compacted version of values
    # compact.gu gives the greatest_unit, compact.v gives the values array
    def compact
      gu = greatest_unit
      puts "gu: #{gu.inspect}"
      return Compact.new(@v, gu) if gu==:hour
      i, st, v = 0, @start_time, []
      while i<@v.size
        v << @v[i]
        next_st = st+1.send(gu)
        h = (next_st-st)/3600
        i = i+h.to_i
        st = next_st
      end
      Compact.new(v, gu)
    end


    # Find the greatest unit time.
    # If the values are contant along the month, the
    # greatest unit is :month
    def greatest_unit
      v = @v.first
      unit = Unit::YEAR # Unit::ETERNITY
      each_with_time do |el|
                
        if v!=el.value
          if el.time.year_changed? and unit>=Unit::YEAR
            unit = Unit::YEAR
          else
            if el.time.month_changed? and unit>=Unit::MONTH
              unit = Unit::MONTH
            else
              if el.time.day_changed? and unit>=Unit::DAY
                unit = Unit::DAY
              else
                unit = Unit::HOUR
                break
              end
            end
          end
        end
        v = el.value
      end
      return Unit.name(unit)
    end



    def if_zero_then(other_array)
      return self if other_array.nil?
      raise NilVectorError if @v.nil? || (other_array.is_a?(TimeArray) && other_array.v.nil?)

      c = self.clone
      if other_array.is_a? Numeric
        default_value = other_array
      else
        c.align_with(other_array)
      end
      
      c.size.times do |i|
        c.set_value(i, default_value || other_array.value(i) || 0.0) if c.value(i).zero?
      end
      c
    end
    alias_method :if_zero, :if_zero_then


    def month_sum
      h = {}
      @v.each_with_index do |value, i|
        time = @start_time + i.hours
        h[time.month] ||= 0.0
        h[time.month] += value
      end
      c = self.clone 
      c.size.times do |i|
        time = @start_time + i.hours
        c.set_value(i, h[time.month])
      end
      c
    end

    # get the count of month hours
    def month_count
      h = {}
      @v.size.times do |i|
        time = @start_time + i.hours
        h[time.month] ||= 0.0
        h[time.month] += 1
      end

      # @v.each_with_index do |value, i|
      #   time = @start_time + i.hours
      #   h[time.month] ||= 0.0
      #   h[time.month] += 1
      # end
      
      c = self.clone 
      c.size.times do |i|
        time = @start_time + i.hours
        c.set_value(i, h[time.month])
      end
      c
    end

    # execute the block (likely a calculation) on each vector element.
    # and return a new time_array obj
    def execute(&block)
      v = @v.map &block
      TimeArray.new(@start_time, v, zone: Time.zone.name)
    end

    # Iterates each hour, the elements are the values of array
    # time_array.each do |value|
    #   value
    # end
    def each(&block)
      @v.each &block
    end


    # Get value associated to a date
    def value_at(datetime_or_year, month=nil, day=nil, hour=nil)
      if datetime_or_year.is_a? Time
        dt = datetime_or_year
      else
        dt = Time.zone.parse("#{datetime_or_year}-#{month}-#{day} #{hour}:00")
      end
      i = ((dt - @start_time)/3600.0).to_i
      raise DateTimeOutRangeError if i<0 || i>(size-1)
      value(i)
    end


    # Iterates each hour, the elements are TimeAndValue objects
    # time_array.each_with_time do |el|
    #   e.time
    #   e.value
    # end
    def each_with_time(&block)
      arr = @v.map.with_index{|v, i| TimeAndValue.new(@start_time+i.hours, v)}
      arr.each(&block)
    end
    # ===========================================================

    private


    def oper(other_array, op)
      return self if other_array.nil?
      raise NilVectorError if @v.nil? || (other_array.is_a?(TimeArray) && other_array.v.nil?)

      c = self.clone
      if other_array.is_a? Numeric
        default_value = other_array
      else
        c.align_with(other_array)
      end
      
      # c.data(Array.new(other_array.size){[:+, :-].include?(op) ? 0.0 : 1.0}) if @v.nil?
      c.size.times do |i|
        c.set_value(i, c.value(i).to_f.send(op, (default_value || other_array.value(i) || 0.0)))
      end
      c
    end

    def set_values(data)
      # the values are always stored as hour values
      @v = @unit==:hour ? Vector.new(data) : expand(data)
    end


    def expand(data)
      vector = Vector.new
      raise NilStartTimeError if @start_time.nil?
      start_time = @start_time.clone

      prev_value = start_time.send(@unit)
      data.each do |v|
        while start_time.send(@unit)==prev_value
          vector << v
          start_time+=1.hour
        end
        prev_value = start_time.send(@unit)
      end
      vector
    end


    def set_start_time(start_time)
      st = read_start_time(start_time)
      @start_time = floor_start_time(st, @unit)
    end



    # start_time must be a Time (or similar) or a String
    # valid start_time "yyyy", "yyyy-m", "yyyy-mm", "yyyy-mm-dd", "yyyy-mm-dd yy"
    def read_start_time(start_time)
      if start_time.is_a?(String)
        start_time.gsub!("/", "-")
        start_time = "20#{r[0]}-01-01" if r = start_time.match(/^\d{2}$/) # "yy"
        start_time = "#{r[0]}-01-01"   if r = start_time.match(/^\d{4}$/) # "yyyy"
        start_time = "#{r[0]}-01"      if r = start_time.match(/^\d{4}-\d{1,2}$/) # "yyyy-m" or "yyyy-mm"
        start_time = Time.zone.parse(start_time)
        raise ArgumentError, "Start time not valid" if start_time.nil?
      end
      start_time
    end





    def floor_start_time(t, unit=:hour)
      return nil if t.nil?
      case @unit
      # when :'15minutes'
      #   t = t - t.sec - (60 * (t.min % 15)) # floor to hour
      when :hour
        t = Time.zone.parse("#{t.year}-#{t.month}-#{t.day} #{t.hour}:00:00")
        # t = t - t.sec - (60 * (t.min % 60)) # floor to hour
      when :day
        t = Time.zone.parse("#{t.year}-#{t.month}-#{t.day}")
      when :month
        t = Time.zone.parse("#{t.year}-#{t.month}-01")
      when :year
        t = Time.zone.parse("#{t.year}-01-01")
      end
      t
    end



    def manage_options(options)
      options = options.symbolize_keys.assert_valid_keys(:unit, :zone)

      # unit
      options = {unit: :hour}.merge(options)
      @unit = options[:unit].to_sym
      Units.validate(@unit)

      # zone
      Time.zone = options[:zone] || "Rome"
    end
  end
end

