require File.dirname(__FILE__) + '/../../../spec_helper'
require 'json'
require 'pp'

describe Logging::Appenders::MQ do
  before(:each) do
    @it = Logging::Appenders::MQ.new('mq', :level => :debug)
    @logger = Logging::Logger['test logger']
    @logger.add_appenders(@it)
  end
  
  it "should write to the message queue" do
    @logger.error "test message"
    
    received_message = nil
    EM.run do
      # connect to the amqp server
      connection = AMQP.connect(:host => 'localhost', :logging => false)
  
      # open a channel on the AMQP connection
      channel = MQ.new(connection)

      # declare a queue on the channel
      queue = MQ::Queue.new(channel, 'exceptions')

      queue.subscribe do |headers, msg|
        received_message = msg
        connection.close{ EM.stop_event_loop }
      end
    end
    
    log = JSON.parse(received_message)
    pp log
    log['message'].should == "test message"
    log['logger'].should == "test logger"
    log['level'].should == "DEBUG"
  end
  
  after(:each) do
    EM.run do
      # connect to the amqp server
      connection = AMQP.connect(:host => 'localhost', :logging => false)
  
      # open a channel on the AMQP connection
      MQ::Queue.new(MQ.new(connection), 'exceptions').delete
      
      connection.close{ EM.stop_event_loop }
    end    
  end
end
