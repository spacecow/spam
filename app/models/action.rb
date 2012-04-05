class Action < ActiveRecord::Base
  belongs_to :filter

  FORWARD_COPY_TO = "forward_copy_to"
  FORWARD_MESSAGE_TO = "forward_message_to"
  MOVE_MESSAGE_TO = "move_message_to"

  validates :destination, :format => {:with => /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/, :message => "is invalid"}, :unless => Proc.new{|e| e.operation == MOVE_MESSAGE_TO}
  validates :destination, :format => {:with => /^[A-Za-z0-9]+$/, :message => "can only contain letters or numbers"}, :if => Proc.new{|e| e.operation == MOVE_MESSAGE_TO}

  def <=>(action)
    self.operation <=> action.operation
  end

  def is_forward?
    operation == FORWARD_MESSAGE_TO || operation == FORWARD_COPY_TO
  end

  def to_file
    if operation == MOVE_MESSAGE_TO
      ".#{destination}/"
    else
      "!#{destination}"
    end
  end

  class << self
    def factory(s,a)
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
      raise "Destination is wrongly formatted: '#{a.first}'." if destinations.size == 0
      destinations.first
    end

    def get_destination(s) 
      data = s.match(/^!(.+)/) 
      return data[1] if data
      data = s.match(/^\.(.*)\//) 
      return data[1]
    end
    def get_operation(s)
      case s
        when ":0"; FORWARD_MESSAGE_TO
        when ":0c"; FORWARD_COPY_TO
        when ":0:"; MOVE_MESSAGE_TO
        else raise "Operation is wrongly formatted: '#{s}'."
      end
    end
    def is_destination?(s) 
      data = s.match(/^!(.+)/) 
      return true if data
      data = s.match(/^\.(.*)\//) 
      return true if data
      #raise "Destination is wrongly formatted: '#{s}'."
    end
  end

  private

    def check_email
      raise "Email is not valid." if data.nil?
    end
end
