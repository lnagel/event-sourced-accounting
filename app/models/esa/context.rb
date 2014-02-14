module ESA
  class Context < ActiveRecord::Base
    attr_accessible :chart, :type
    attr_readonly   :chart

    belongs_to :chart
    has_many :accounts, :through => :chart
    has_many :rulesets, :through => :chart

    has_many :unscoped_events, :through => :rulesets, :source => :events
    has_many :unscoped_flags, :through => :rulesets, :source => :flags
    has_many :unscoped_transactions, :through => :accounts, :source => :transactions
    has_many :unscoped_amounts, :through => :accounts, :source => :amounts

    # has_many :planets, :conditions => Planet.life_supporting.where_values,
    # :order => Planet.life_supporting.order_values
    after_initialize :default_values
    validates_presence_of :chart

    def events
      self.apply(self.unscoped_events)
    end

    def flags
      self.apply(self.unscoped_flags)
    end

    def transactions
      self.apply(self.unscoped_transactions)
    end

    def amounts
      self.apply(self.unscoped_amounts)
    end

    def apply(relation)
      @filters.inject(relation){|r,filter| filter.(r)}
    end

    protected

    def default_values
      @filters = []
    end
  end
end
