module Bvr
  class PhoneCollection
    include Enumerable

    API_COMMANDS = {
      add: 'changeuserinfo'
    }

    attr_reader :collection, :customer_id

    def initialize(customer_id)
      @collection = []
      @customer_id = customer_id
    end

    def self.add(customer_id, phone, add="add")
      params = {
        command: API_COMMANDS[:add],
        customer: customer_id,
        geocallcli_options: add,
        geocallcli: phone
      }

      Bvr.connection.get(params)
    end

    def add(phone)
      return true if self.collection.include? phone

      response = Bvr::PhoneCollection.add(self.customer_id, phone.number)
      return false unless response['Result'][0] == 'Success'

      self.collection << phone
      true
    end

    def each(&block)
      @collection.each { |em| block.call(em) }
    end

    def rm(phone)
      return false unless self.collection.include? phone

      response = Bvr::PhoneCollection.add(self.customer_id, phone.number, "delete")
      return false unless response['Result'][0] == 'Success'

      self.collection.delete phone
      true
    end

  private

    def method_missing(method, arg, &block)
      return super unless self.collection.respond_to? method

      self.collection.send(method, arg, &block)
    end
  end
end
