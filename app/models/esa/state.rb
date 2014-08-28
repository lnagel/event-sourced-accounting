module ESA
  # Records the last known state of the given Accountable object
  #
  # @author Lenno Nagel
  class State < ActiveRecord::Base
    attr_accessible :accountable, :processed_at, :unprocessed
    attr_readonly   :accountable

    belongs_to :accountable, :polymorphic => true
  end
end
