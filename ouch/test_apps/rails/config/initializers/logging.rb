
Logging.configure {

  logger(:root) {
    level      :info
    additive   false
    trace      true
    appenders  %w[mq growl logfile]
  }
  
  appender('mq') {
    type   'MQ'
    level  :error
    layout {
      type       'Parseable'
      format_as  :json   
    }
  }

  appender('growl') {
    type   'Growl'
    level  :debug
    layout {
      type       'Basic'
      format_as  :string
    }
  }

  appender('logfile') {
    type      'File'
    level     :debug
    filename  'tmp/temp.log'
    truncate  true
    layout {
      type         'Pattern'
      date_method  'to_s'
      pattern      '[%d] %l  %c : %m\n'
    }
  }

}  # logging configuration

puts "logging initialized"
raise("eek") unless Logging::Logger[:root].trace