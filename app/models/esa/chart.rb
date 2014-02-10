module ESA
  # The Chart class represents an organized set of accounts in the system.
  #
  # @author Lenno Nagel
  class Chart < ActiveRecord::Base
    include Extendable

    attr_accessible :name

    has_many :accounts
    has_many :rulesets

    after_initialize :default_values

    validates_presence_of :name
    validates_uniqueness_of :name

    private

    def default_values
      self.name ||= "Chart of Accounts"
    end
  end
end
