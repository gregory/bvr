module Bvr
  class Customer
    API_COMMANDS = {
      find: "getuserinfo"
    }

    attr_accessor :id, :email, :raw_blocked, :credit

    def self.find(id)
      params = {
        command: API_COMMANDS[:find],
        customer: id
      }

      response = Bvr.connection.get(params)

      response['Failed'].nil? ? self.new_from_response(response) : nil
    end

    def self.new_from_response(h)
      self.new.tap do |customer|
        customer.id      = h["Customer"][0]
        customer.email   = h["EmailAddress"][0]
        customer.raw_blocked = h["Blocked"][0]
        customer.credit  = Bvr::Credit.new(h["SpecificBalance"][0], h["Balance"][0])
      end
    end

    def blocked?
      self.raw_blocked == "True"
    end

    def calls(options={})
      return @_calls if @_calls && @_calls.query_params == options
      @_calls = Bvr::CallCollection.find_by_customer_id(self.id, options)
    end
  end
end
