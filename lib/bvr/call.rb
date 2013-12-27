module Bvr
  class Call
    API_COMMANDS= {
      find
    }
    attr_accessor :id, :calltype, :start_time, :dest, :duration, :charge

    def duration
      Time.parse(self.raw_duration, start_time)
    end
  end
end
