# * Here you must define your `Factory` class.
# * Each instance of Factory could be stored into variable. The name of this variable is the name of created Class
# * Arguments of creatable Factory instance are fields/attributes of created class
# * The ability to add some methods to this class must be provided while creating a Factory
# * We must have an ability to get/set the value of attribute like [0], ['attribute_name'], [:attribute_name]
#
# * Instance of creatable Factory class should correctly respond to main methods of Struct
# - each
# - each_pair
# - dig
# - size/length
# - members
# - select
# - to_a
# - values_at
# - ==, eql?
class Factory
    def self.new(*args, &block)
      return const_set(args.shift, create_class(args, &block)) if args.first.is_a?(String)

      create_class(args, &block)
    end
  
    class << self
      private
  
      def create_class(args, &block)
        Class.new do
          attr_accessor(*args, &block)
          module_eval(&block) if block_given?
  
          define_method :initialize do |*attribute|
            valid_argument_number(attribute, args)
            args.each.with_index do |arg, i|
              instance_variable_set("@#{arg}", attribute[i])
            end
          end

          def valid_argument_number(attribute, args)
            raise ArgumentError if attribute.size > args.size
          end

          def ==(other)
            instance_variables.each do |var|
              return false unless instance_variable_get(var) == other.instance_variable_get(var)
            end
            true
          end

          def [](variable)
            return instance_variable_get(instance_variables[variable]) if variable.is_a?(Integer)

            instance_variable_get("@#{variable}")
          end

          def []=(variable, value)
            variable = "@#{variable}".to_sym
            instance_variable_set(variable, value)
          end

          def dig(*value)
            value.inject(self) do |key, val|
              return nil if key[val].nil?
              key[val]
            end
          end

          def to_a
            instance_variables.map { |variable| instance_variable_get(variable) }
          end

          def to_h
            instance_variables.map { |variable| variable.to_s.delete('@') }.zip(self.to_a).to_h
          end

          def each(&block)
            self.to_a.each(&block)
          end

          def each_pair(&block)
            self.to_h.each_pair(&block)
          end

        end
      end
    end
  end
