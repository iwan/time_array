module TimeArray
  module Units
    LIST = [:hour, :day, :wday, :month, :year]

    def self.valid?(u)
      LIST.include?(u.to_sym)
    end
    
    def self.validate(u)
      raise ArgumentError, "Time unit is not valid" if !self.valid?(u) 
    end
  end
end