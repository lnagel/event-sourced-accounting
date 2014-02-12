module ESA
  module Traits
    #
    # https://gist.github.com/tlowrimore/5257360
    # 
    # OR's together provided scopes, returning an ActiveRecord::Relation.
    # This implementation is smart enough to not only handle your _where_
    # clauses, but it also takes care of your joins!
    #
    module OrScope
      def self.included(base)
        base.send :extend, ClassMethods
      end

      module ClassMethods
        def or_scope(*scopes)
          conditions = 
            scopes
              .map { |scope| "(#{scope.where_clauses.map{ |clause| "(#{clause})"}.join(" AND ")})" }
              .join(" OR ")
              
          relationships =
            scopes
              .map { |scope| scope.joins_values }
              .flatten
              .uniq
              
          joins(*relationships).where(conditions)
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ESA::Traits::OrScope
