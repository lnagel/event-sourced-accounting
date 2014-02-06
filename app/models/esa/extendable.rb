module ESA
  module Extendable
    extend ActiveSupport::Concern

    included do |base|
      cattr_accessor :extensions
      self.extensions = {}

      def simple_type
        self.type.split('::').last
      end

      def self.register_extension(accountable, extension)
        self.extensions[accountable] = extension
      end

      def self.extension_name(accountable)
        if accountable.is_a? Class
          if accountable.respond_to? :accountable_name
            self.extensions[accountable.accountable_name]
          else
            self.extensions[accountable.name]
          end
        elsif accountable.is_a? Object
          extension_name(accountable.class)
        else
          self.extensions[accountable]
        end
      end

      def self.extension_class(accountable)
        if extension_name(accountable).present?
          extension_name(accountable).constantize
        else
          nil
        end
      end

      def self.accountable_name(extension=self)
        if extension.is_a? Class
          self.extensions.key(extension.name)
        else
          self.extensions.key(extension)
        end
      end

      def self.accountable_class(extension=self)
        if accountable_name(extension).present?
          accountable_name(extension).constantize
        else
          nil
        end
      end

      def self.list_extensions
        self.extensions.each do |accountable, extension|
          puts "#{accountable} --> #{extension}"
        end
        nil
      end
    end
  end
end
