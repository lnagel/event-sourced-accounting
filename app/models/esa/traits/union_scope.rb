module ESA
  module Traits
    #
    # https://gist.github.com/tlowrimore/5162327
    # 
    # Unions multiple scopes on a model, and returns an instance of ActiveRecord::Relation.
    #
    module UnionScope
      def self.included(base)
        base.send :extend, ClassMethods
      end

      module ClassMethods
        def union_scope(*scopes)
          id_column = "#{table_name}.id"
          sub_query = scopes.map { |s| s.select(id_column).to_sql }.join(" UNION ")
          where "#{id_column} IN (#{sub_query})"
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, ESA::Traits::UnionScope
