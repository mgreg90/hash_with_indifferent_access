# require 'bundler/inline'

# gemfile do
#   gem 'pry'
# end

module Mike
  class HashWithIndifferentAccess

    def initialize(hash)
      @source_hash = hash.map do |k, v|
        k = k.is_a?(Symbol) ? k.to_s : k
        v = v.is_a?(Hash) ? HashWithIndifferentAccess.new(v) : v
        v = if v.respond_to?(:map)
          v.map do |value|
            value.is_a?(Hash) ? HashWithIndifferentAccess.new(value) : value
          end
        else
          v
        end
        [k, v]
      end.to_h

      def [](key)
        if key.is_a? Symbol
          @source_hash[key.to_s]
        else
          @source_hash[key]
        end
      end

      def []=(key, value)
        if key.is_a? Symbol
          @source_hash[key.to_s] = value
        else
          @source_hash[key] = value
        end
      end

      def inspect
        obj_id = super.match(/(?<=:)(?<obj_id>0x([a-z]|\d)+)/)[:obj_id]
        "#<HashWithIndifferentAccess:#{obj_id}> #{@source_hash.inspect}"
      end

      def to_s
        @source_hash.to_s
      end

      def method_missing(method, *args, &block)
        @source_hash.send(:method, *args, &block)
      end

      def to_h
        @source_hash
      end

    end

  end

  module CanConvertToHashWithIndifferentAccess

    def with_indifferent_access
      HashWithIndifferentAccess.new(self)
    end

  end
end

Hash.include(Mike::CanConvertToHashWithIndifferentAccess)

# hash1 = {
#   a: 'a',
#   'b' => 'b',
#   'nested_hash' => { a: 'a', 'b' => 'b' },
#   nested_array: [{ a: 'a', 'b' => 'b'}]
# }.with_indifferent_access
# binding.pry