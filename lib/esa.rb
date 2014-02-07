# ESA
require "rails"
require "enumerize"
module ESA
  class Engine < Rails::Engine
    isolate_namespace ESA
  end
end
