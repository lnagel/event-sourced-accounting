module ESA
  class ContextProvider
    def self.provided_types
      []
    end

    def self.check_subcontexts(context, namespace, options = {})
      existing = existing_subcontexts(context, namespace)
      contained = contained_subcontexts(context, namespace, existing, options)

      created = contained - existing
      created.each do |sub|
        sub.save if sub.new_record? or sub.changed?
      end

      unregistered = contained - context.subcontexts
      context.subcontexts += unregistered

      removed = existing - contained
      context.subcontexts -= removed

      removed.each(&:destroy) if context.can_be_persisted?

      contained
    end

    def self.context_id(context, options = {})
      []
    end

    def self.contained_ids(context, options = {})
      []
    end

    def self.existing_subcontexts(context, namespace, options = {})
      context.subcontexts.where(type: provided_types, namespace: namespace).all
    end

    def self.contained_subcontexts(context, namespace, existing, options = {})
      contained_ids = contained_ids(context, options)
      existing_grouped = existing.group_by{|sub| context_id(sub, options)}
      existing_ids = existing_grouped.keys

      new_ids = contained_ids - existing_ids

      new_subcontexts = new_ids.map do |id|
        instantiate(context, namespace, id, options)
      end

      keep_subcontexts = existing_grouped.map do |id,group|
        (id.in? contained_ids) ? group.first : nil
      end.compact

      new_subcontexts + keep_subcontexts
    end
  end
end
