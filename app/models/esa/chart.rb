module ESA
  # The Chart class represents an organized set of accounts in the system.
  #
  # @author Lenno Nagel
  class Chart < ActiveRecord::Base
    attr_accessible :name
    
    has_many :accounts
    validates_presence_of :name
    validates_uniqueness_of :name
  end
end
