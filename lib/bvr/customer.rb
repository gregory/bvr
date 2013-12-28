module Bvr
  class Customer
    API_COMMANDS = {
      find: "getuserinfo",
      create: "createcustomer"
    }

    CREATE_OPTIONS = {
      mendatory: [
        :username,
        :password,
        :command,
        :customer,
        :customerpassword
      ],
      optional: [
        :geocalicli,
        :tariffrate
      ]
    }

    attr_accessor :id, :email, :raw_blocked, :credit

    def self.create(options)
      params = { command: API_COMMANDS[:create] }

      options.merge!(params)
      raise ArgumentError.new('Invalid or unknown Argument') unless self.valid_create_options?(options)

      Bvr.connection.get(options)
    end

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
        customer.id      = h["Customer"]
        customer.email   = h["EmailAddress"]
        customer.raw_blocked = h["Blocked"]
        customer.credit  = Bvr::Credit.new(h["SpecificBalance"], h["Balance"])
      end
    end

    def blocked?
      self.raw_blocked == "True"
    end

    def calls(options={})
      return @_calls if @_calls && @_calls.query_params == options
      @_calls = Bvr::CallCollection.find_by_customer_id(self.id, options)
    end

  private

    def self.valid_create_options?(options)
      return false if options.empty?
      valid_options = CREATE_OPTIONS.values.flatten
      return false unless options.keys.all? { |option| valid_options.include? option }
      CREATE_OPTIONS[:mendatory].all? { |option| options.keys.include? option }
    end
  end
end
