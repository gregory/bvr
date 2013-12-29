module Bvr
  class Credit < Struct.new(:raw_specific_balance, :raw_balance, :customer)
    API_COMMANDS= {
      add: 'settransaction'
    }

    def self.add(id, amount)
      params = {
        command: API_COMMANDS[:add],
        customer: id,
        amount: amount
      }

      Bvr.connection.get(params)
    end

    def add(amount)
      response = Bvr::Credit.add(self.customer.id, amount)
      return false unless response['Result'] == 'Success'

      add_amount(amount) && true
    end


    def balance
      @_balance ||= Float(self.raw_balance)
    end

    def rm(amount)
      self.add(-1 * amount)
    end

    def specific_balance
      @_specific_balance ||= Float(self.raw_specific_balance)
    end

  private

    def add_amount(amount)
      @_specific_balance = self.specific_balance + Float("%.5f" % amount)
      @_balance          = self.balance          + Float("%.2f" % amount)

      self.raw_specific_balance = "#{@_specific_balance}"
      self.raw_balance = "#{@_balance}"
    end
  end
end
