class Action < ActiveRecord::Base
  belongs_to :filter

  FORWARD_COPY_TO = "forward_copy_to"
  FORWARD_MESSAGE_TO = "forward_message_to"

  class << self
    def forward_factory(s,a)
      op = get_operation(s)
      dest = strip_destination(a)
      Action.create(destination:dest,operation:op)
    end

    def strip_destination(a)
      destinations = []
      while !a.empty? && is_destination?(a.first)
        destinations << get_destination(a.shift)
      end
      raise "Can only create one action." if destinations.size > 1
      raise "Action is wrongly formatted: '#{a.first}'." if destinations.size == 0
      destinations.first
    end

    def get_destination(s) s.match(/!(.+)/)[1] end
    def get_operation(s)
      case s
        when ":0"; FORWARD_MESSAGE_TO
        when ":0c"; FORWARD_COPY_TO
        else raise "Operation is wrongly formatted: '#{s}'."
      end
    end
    def is_destination?(s) s.match(/!(.+)/) end
  end
end
