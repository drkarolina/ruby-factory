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
          raise ArgumentError if attribute.size > args.size

          args.zip(attribute).each { |key, value| public_send("#{key}=", value) }
        end

        def ==(other)
          to_a == other.to_a
        end

        alias_method :eql?, :==

        def [](variable)
          return to_a[variable] if variable.is_a?(Integer)

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
          instance_variables.map { |variable| variable.to_s.delete('@') }.zip(to_a).to_h
        end

        def each(&block)
          to_a.each(&block)
        end

        def each_pair(&block)
          to_h.each_pair(&block)
        end

        def select(&block)
          to_a.select(&block)
        end

        def members
          instance_variables.map { |variable| variable.to_s.delete('@').to_sym }
        end

        def values_at(*args)
          args.map { |index| self[index] }
        end

        def size
          to_a.size
        end

        alias_method :length, :size
      end
    end
  end
end
