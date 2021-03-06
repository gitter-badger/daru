require 'nmatrix' unless jruby?

module Daru
  module Accessors

    # Internal class for wrapping NMatrix
    class NMatrixWrapper
      module Statistics
        # def average_deviation_population m=nil
        #   m ||= self.mean
        #   (self.reduce(0){|memo, val| val + (val - m).abs})/self.length
        # end

        # def coefficient_of_variation
        #   self.standard_deviation_sample/self.mean
        # end

        # def count x=false
        #   if block_given?
        #     self.reduce(0){|memo, val| memo += 1 if yield val; memo}
        #   else
        #     val = self.frequencies[x]
        #     val.nil? ? 0 : val
        #   end
        # end

        # def factors
        #   index = @data.sorted_indices
        #   index.reduce([]){|memo, val| memo.push(@data[val]) if memo.last != @data[val]; memo}
        # end

        # def frequencies
        #   index = @data.sorted_indices
        #   index.reduce({}){|memo, val| memo[@data[val]] ||= 0; memo[@data[val]] += 1; memo}
        # end

        # def has_missing_data?
        #   @missing_data
        # end

        # def is_valid?
        #   true
        # end

        # def kurtosis(m=nil)
        #   m ||= self.mean
        #   fo=self.reduce(0){|a, x| a+((x-m)**4)}
        #   fo.quo(self.length*sd(m)**4)-3
        # end

        def mean
          @data[0...@size].mean.first
        end

        # def median
        #   self.percentil(50)
        # end

        # def median_absolute_deviation
        #   m = self.median
        #   self.recode{|val| (val-m).abls}.median
        # end

        # def mode
        #   self.frequencies.max
        # end

        def n_valid
          @size
        end

        # def percentil(percent)
        #   index = @data.sorted_indices
        #   pos = (self.length * percent)/100
        #   if pos.to_i == pos
        #     @data[index[pos.to_i]]
        #   else
        #     pos = (pos-0.5).to_i
        #     (@data[index[pos]] + @data[index[pos+1]])/2
        #   end
        # end

        def product
          @data.inject(1) { |m,e| m*e }
        end

        # def proportion(val=1)
        #   self.frequencies[val]/self.n_valid
        # end

        # def proportions
        #   len = self.n_valid
        #   self.frequencies.reduce({}){|memo, arr| memo[arr[0]] = arr[1]/len}
        # end

        # def push(val)
        #   self.expand(self.length+1)
        #   self[self.length-1] = recode
        # end

        def range
          max - min
        end

        # def ranked
        #   sum = 0
        #   r = self.frequencies.sort.reduce({}) do |memo, val|
        #     memo[val[0]] = ((sum+1) + (sum+val[1]))/2
        #     sum += val[1]
        #     memo
        #   end
        #   Mikon::DArray.new(self.reduce{|val| r[val]})
        # end

        # def skew(m=nil)
        #   m ||= self.mean
        #   th = self.reduce(0){|memo, val| memo + ((val - m)**3)}
        #   th/((self.length)*self.sd(m)**3)
        # end

        # def standard_deviation_population(m=nil)
        #   m ||= self.mean
        #   Maths.sqrt(self.variance_population(m))
        # end

        # def standard_deviation_sample(m=nil)
        #   if !m.nil?
        #     Maths.sqrt(variance_sample(m))
        #   else
        #     @data.std.first
        #   end
        # end

        # def standard_error
        #   self.standard_deviation_sample/(Maths.sqrt(self.length))
        # end

        # def sum_of_squared_deviation
        #   self.reduce(0){|memo, val| val**2 + memo}
        # end

        # def sum_of_squares(m=nil)
        #   m ||= self.mean
        #   self.reduce(0){|memo, val| memo + (val-m)**2}
        # end

        def sum
          @data.inject(:+)
        end

        # def variance_sample(m=nil)
        #   m ||= self.mean
        #   self.sum_of_squares(m)/(self.length-1)
        # end
      end # module Statistics

      include Statistics
      include Enumerable

      def each(&block)
        @data.each(&block)
      end

      def map!(&block)
        @data.map!(&block)
      end

      alias_method :recode, :map
      alias_method :recode!, :map!

      attr_reader :size, :data, :missing_data, :ntype
      
      def initialize vector, context, ntype=:int32
        @size = vector.size
        @ntype = ntype
        @data = NMatrix.new [@size*2], vector.to_a, dtype: ntype
        @missing_data = false
        @context = context
        # init with twice the storage for reducing the need to resize
      end

      def [] index
        return @data[index] if index < @size
        nil
      end
 
      def []= index, value
        resize     if index >= @data.size
        @size += 1 if index == @size
        
        if value.nil?
          @missing_data = true
          @data = @data.cast(dtype: :object)
        end
        @data[index] = value
      end 
 
      def == other
        @data == other and @size == other.size
      end
 
      def delete_at index
        arry = @data.to_a
        arry.delete_at index
        @data = NMatrix.new [(2*@size-1)], arry, dtype: @ntype
        @size -= 1
      end
 
      def index key
        @data.to_a.index key
      end
 
      def << element
        resize if @size >= @data.size
        self[@size] = element

        @size += 1
      end
 
      def to_a
        @data.to_a
      end
 
      def dup
        NMatrixWrapper.new @data.to_a, @context, @ntype
      end

      def resize size = @size*2
        raise ArgumentError, "Size must be greater than current size" if size < @size

        @data = NMatrix.new [size], @data.to_a
      end
    end
  end
end