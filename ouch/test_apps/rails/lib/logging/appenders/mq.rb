require 'mq'

class Logging::Appenders::MQ < Logging::Appender
  
  class JSONExceptionLayout < Logging::Layouts::Parseable
    def initialize(options = {})
      super(
        :style => :json, 
        :items  => %w[logger timestamp level message file line method pid])
    end
    
    def format_obj(data)
      { :foo => "test" }
    end
    
    # def format_as_json(value)
    #   return JSON.unparse(value) if value.is_a?(Hash)
    #   super
    # end
  end
  
  def initialize(name, options = {})
    options[:layout] = JSONExceptionLayout.new
    super
  end
  
  def write( event )
    publish(@layout.format(event))
  end
  
  # Publish a (string) message to a queue. The queue 'name' should
  # be such that Queue[name].name is valid.
  def publish(msg)
    EM.run do
      # connect to the amqp server
      connection = AMQP.connect(:host => 'localhost', :logging => false)
  
      # open a channel on the AMQP connection
      channel = MQ.new(connection)

      # declare a queue on the channel
      queue = MQ::Queue.new(channel, 'exceptions')

      # create a fanout exchange
      exchange = MQ::Exchange.new(channel, :fanout, 'all queues')

      # bind the queue to the exchange
      queue.bind(exchange)

      # publish a message to the exchange
      exchange.publish(msg.to_s)
      
      connection.close{ EM.stop_event_loop }
    end
  end
end