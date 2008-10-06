module Pacecar
  module Presence
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def self.extended(base)
        base.send :define_presence_scopes
      end

      protected

      def define_presence_scopes
        column_names.each do |name|
          named_scope "#{name}_present".to_sym, :conditions => "#{name} is not null"
          named_scope "#{name}_missing".to_sym, :conditions => "#{name} is null"
        end
      end

    end
  end
end
