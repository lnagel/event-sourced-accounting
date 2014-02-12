module ESA
  module Associations
    module ContextExtension
      def with_context(context)
        with_filters(context.filters)
      end

      def with_filters(filters = [])
        if filters.respond_to? :each
          filters.inject(scoped){|scoped,filter| filter.(scoped)}
        else
          scoped
        end
      end
    end
  end
end
