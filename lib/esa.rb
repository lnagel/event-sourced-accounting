# ESA
require "rails"
module ESA
  class Engine < Rails::Engine
    isolate_namespace ESA
  end
end
