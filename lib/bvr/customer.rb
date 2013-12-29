module Bvr
  class Customer
    API_COMMANDS = {
      find: "getuserinfo",
      create: "createcustomer",
      block: "changeuserinfo",
      authenticate: "validateuser",
      changepassword: 'changepassword'
    }

    BLOCKED_VALUES = {
      true => 'True',
      false => 'False'
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

    attr_accessor :id, :email, :raw_blocked, :credit, :password, :phones

    def initialize(id)
      @id = id
      @phones = Bvr::PhoneCollection.new(id)
    end

    def self.authenticate(id, password)
      params = {
        command: API_COMMANDS[:authenticate],
        customer: id,
        customerpassword: password
      }

      response = Bvr.connection.get(params)
      response['Result'] == 'Success'
    end

    def self.block(id, block=true)
      params = {
        command: API_COMMANDS[:changeuserinfo],
        customer: id,
        customerblocked: block
      }

      raise ArgumentError.new('Please provide a boolean') unless !!block == block

      Bvr.connection.get(params)
    end

    def self.change_password(id, old_password, new_password)
      params = {
        command: API_COMMANDS[:changepassword],
        customer: id,
        oldcustomerpassword: old_password,
        newcustomerpassword: new_password
      }

      Bvr.connection.get(params)
    end

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
      self.new(h["Customer"]).tap do |customer|
        customer.email   = h["EmailAddress"]
        customer.raw_blocked = h["Blocked"]
        customer.credit  = Bvr::Credit.new(h["SpecificBalance"], h["Balance"], customer)
        h['GeocallCLI'].each{ |number| customer.phones << Bvr::Phone.new(number)}
      end
    end

    def blocked?
      self.raw_blocked == BLOCKED_VALUES[true]
    end

    def block!
      response = Bvr::Customer.block(self.id, true)

      if response['Result'][0] == 'Success'
        self.raw_blocked = BLOCKED_VALUES[true]
      end

      return response['Result'][0] == 'Success'
    end

    def change_password(new_password)
      response = Bvr::Customer.change_password(self.id, self.password, new_password)
      return false if response['Result'] != 'Success'

      self.password = new_password
    end

    def unblock!
      response = Bvr::Customer.block(self.id, false)

      if response['Result'][0] == 'Success'
        self.raw_blocked = BLOCKED_VALUES[false]
      end

      return response['Result'][0] == 'Success'
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
