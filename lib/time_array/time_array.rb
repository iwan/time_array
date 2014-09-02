require 'active_support/core_ext/time/zones'
require 'active_support/core_ext/time/calculations'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/hash'


module TimeArray
  class TimeArray
    attr_reader :start_time, :v, :unit

    def initialize(start_time, values=Vector.new, options={})
      manage_options(options)
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

    # Set all vector values to a new value
    def all_to(new_value)
      @v = Vector.new(@v.size, new_value)
      # @v.map!{|e| e=new_value}
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


    # Return the average of values
    # def avg(options = {})
    #   c = count(options)
    #   return nil if c.zero? # if the array is empty will be returned nil
    #   sum(options) / c
    # end


    private

    def set_values(data)
      # the values are always stored as hour values
      if unit==:hour
        @v = Vector.new(data)
      else
        start_time = (@start_time.nil? ? nil : @start_time.clone)
        @v = Vector.new(data.size)

        prev_value = start_time.send(@unit)
        data.each do |v|
          while start_time.send(@unit)==prev_value
            @v << v
            start_time+=1.hour
          end
          prev_value = start_time.send(unit)
        end
      end

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

