module Bvr
  class Phone
    attr_accessor :number

    def initialize(phone_number)
      @number = phone_number
    end

    def self.phone_number_parser(phone_number)
      self.new(phone_number)
    end
  end
end
