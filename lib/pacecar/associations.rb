module Pacecar
  module Associations
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def has_recent_records(*names)
        names.each do |name|
          scope "recent_#{name}_since".to_sym, lambda { |since|
            {
              :conditions => [conditions_for_name(name), { :since_time => since }]
            }
          }
        end
        unless names.first == names.last
          scope "recent_#{names.join('_or_')}_since".to_sym, lambda { |since|
            {
              :conditions => [names.collect { |name| conditions_for_name(name) }.join(' or '), { :since_time => since }]
            }
          }
          scope "recent_#{names.join('_and_')}_since".to_sym, lambda { |since|
            {
              :conditions => [names.collect { |name| conditions_for_name(name) }.join(' and '), { :since_time => since }]
            }
          }
        end
      end

      def has_updated_records(*names)
        names.each do |name|
          scope "updated_#{name}_since".to_sym, lambda { |since|
            {
              :conditions => [updated_conditions_for_name(name), { :since_time => since }]
            }
          }
        end
        unless names.first == names.last
          scope "updated_#{names.join('_or_')}_since".to_sym, lambda { |since|
            {
              :conditions => [names.collect { |name| updated_conditions_for_name(name) }.join(' or '), { :since_time => since }]
            }
          }
          scope "updated_#{names.join('_and_')}_since".to_sym, lambda { |since|
            {
              :conditions => [names.collect { |name| updated_conditions_for_name(name) }.join(' and '), { :since_time => since }]
            }
          }
        end
      end

      
      protected

      def conditions_for_name(name)
        "((select count(*) from #{connection.quote_table_name(name)} where #{connection.quote_table_name(name)}.#{connection.quote_column_name reflections[name].primary_key_name} = #{quoted_table_name}.#{connection.quote_column_name primary_key} and #{connection.quote_table_name(name)}.#{connection.quote_column_name("created_at")} > :since_time) > 0)"
      end

      def updated_conditions_for_name(name)
        "((select count(*) from #{connection.quote_table_name(name)} where #{connection.quote_table_name(name)}.#{connection.quote_column_name reflections[name].primary_key_name} = #{quoted_table_name}.#{connection.quote_column_name primary_key} and #{connection.quote_table_name(name)}.#{connection.quote_column_name("updated_at")} > :since_time) > 0)"
      end
      
    end
  end
end
