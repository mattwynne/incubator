require 'rubygems'
require 'mq'
require 'couchrest'
require 'json'
require 'pp'

module Ouch::LogRecorder
  def self.start
    @db = CouchRest.database!("http://127.0.0.1:5984/exceptions")
    EM.run do
      # connect to the amqp server
      connection = AMQP.connect(:host => 'localhost', :logging => false)
  
      # open a channel on the AMQP connection
      channel = MQ.new(connection)

      # declare a queue on the channel
      queue = MQ::Queue.new(channel, 'exceptions')

      Signal.trap('INT') { puts "stopping..."; connection.close{ EM.stop_event_loop } }
      Signal.trap('TERM'){ puts "OK! stopping..."; connection.close{ EM.stop_event_loop } }
      
      puts "subscribing to exceptions queue..."
      queue.subscribe do |headers, msg|
        puts "exception received"
        doc = JSON.parse(msg)
        pp doc
        
        puts "saving to couchdb"
        
        begin
          response = @db.save_doc(doc)
        rescue Exception => exception
          puts "failed to save: #{exception}"
        end
      end
    end
  end
end