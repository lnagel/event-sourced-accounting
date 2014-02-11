module ESA
  module Extendable
    extend ActiveSupport::Concern

    included do |base|
      cattr_accessor :esa_extensions
      self.esa_extensions = {}

      def simple_type
        self.type.split('::').last
      end

      def self.register_extension(expression, extension)
        self.esa_extensions[expression] = extension
      end

      def self.lookup_extension(name)
        if self.esa_extensions.present?
          matches = self.esa_extensions.map do |expr,extension|
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
        else
          self.name
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
          extension_class(accountable).instance_for(accountable)
        else
          nil
        end
      end

      def self.instance_for(accountable)
        self.first_or_create
      end

      def self.accountable_name(extension=self)
        registered_keys_for(extension).find{|k| k.is_a? String}
      end

      def self.registered_keys_for(extension=self)
        if extension.is_a? Class
          self.esa_extensions.select{|k,v| v == extension.name}.keys
        elsif extension.is_a? Object and not extension.is_a? String
          registered_keys_for(extension.class)
        else
          self.esa_extensions.select{|k,v| v == extension}.keys
        end
      end

      def self.list_extensions
        self.esa_extensions.each do |accountable, extension|
          puts "#{accountable} --> #{extension}"
        end
        nil
      end
    end
  end
end
