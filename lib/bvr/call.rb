module Bvr
  class Call
    attr_accessor :id, :calltype, :raw_start_time, :raw_dest, :raw_duration, :charge

    def self.new_from_response(h)
      self.new.tap do |call|
        call.id             = h['CallId']
        call.calltype       = h['CallType']
        call.raw_start_time = h['StartTime']
        call.raw_dest       = h['Destination']
        call.raw_duration   = h['Duration']
        call.charge         = h['Charge']
      end
    end

    def duration
      @_duration ||= Time.parse(self.raw_duration, self.start_time)
    end

    def dest
      @_dest ||= Bvr::Phone.new(self.raw_dest)
    end

    def start_time
      @_start_time ||= Time.parse(self.raw_start_time)
    end
  end
end
