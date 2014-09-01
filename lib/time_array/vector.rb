module TimeArray
  class Vector < Array
    def clone
      Vector.new(self)
    end

    def sum_all
      inject(0.0){|total, n| total + (n||0.0) }
    end

    def sum_positive
      inject(0.0){|total, n| total + (n>0.0 ? n : 0.0) }
    end

    def sum_negative
      inject(0.0){|total, n| total + (n<0.0 ? n : 0.0) }
    end

    def count_positive
      count{|e| e>0.0}
    end

    def count_non_positive
      count{|e| e<=0.0}
    end

    def count_non_negative
      count{|e| e>=0.0}
    end

    def count_negative
      count{|e| e<0.0}
    end

    def count_non_zero
      count{|e| e!=0.0}
    end

    def count_zero
      count{|e| e==0.0}
    end

    def count_all
      size
    end
  end
end
