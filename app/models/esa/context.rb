module ESA
  class Context
    attr_reader :filters

    def initialize(filters = [])
      @filters = filters
    end

    def apply(relation)
      @filters.inject(relation){|r,filter| filter.(r)}
    end
  end
end
