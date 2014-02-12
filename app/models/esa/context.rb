module ESA
  class Context
    attr_reader :filters

    def initialize(filters = [])
      @filters = filters
    end
  end
end
