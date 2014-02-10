module ESA
  module Extendable
    extend ActiveSupport::Concern

    included do |base|
      cattr_accessor :extensions
      self.extensions = {}

      def simple_type
        self.type.split('::').last
      end

      def self.register_extension(expression, extension)
        self.extensions[expression] = extension
      end

      def self.lookup_extension(name)
        matches = self.extensions.map do |expr,extension|
          if expr.is_a? Regexp and expr.match(name).present?
            extension
          elsif expr.is_a? String and expr == name
            extension
          else
            nil
          end
        end.compact

        if matches.present?
          matches.first
        else
          nil
        end
      end

      def self.extension_name(accountable)
        if accountable.is_a? Class
          if accountable.respond_to? :accountable_name
            lookup_extension(accountable.accountable_name)
          else
            lookup_extension(accountable.name)
          end
        elsif accountable.is_a? Object and not accountable.is_a? String
          extension_name(accountable.class)
        else
          lookup_extension(accountable)
        end
      end

      def self.extension_class(accountable)
        if extension_name(accountable).present?
          extension_name(accountable).constantize
        else
          nil
        end
      end

      def self.extension_instance(accountable)
        if extension_class(accountable).present?
          extension_class(accountable).first_or_create
        else
          nil
        end
      end

      def self.accountable_name(extension=self)
        registered_keys_for(extension).find{|k| k.is_a? String}
      end

      def self.registered_keys_for(extension)
        if extension.is_a? Class
          self.extensions.select{|k,v| v == extension}.keys
        elsif extension.is_a? Object and not extension.is_a? String
          registered_keys_for(extension.class)
        else
          self.extensions.select{|k,v| v == extension}.keys
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
