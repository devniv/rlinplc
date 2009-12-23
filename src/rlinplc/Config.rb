#!/usr/bin/ruby

require 'yaml'
require 'singleton'

class RlinConfig
  include Singleton
  include Logging
  attr_reader :lang, :langparams, :input, :output, :variables, :mainlogger


  def initialize()
      c = YAML::load(IO.read('config.yml'))
      @lang = c['lang']
      @langparams = c['langparams']
      @input = c['input']
      @output = c['output']
      @variables = c['variables']
      @mainlogger = Log.instance
      debuglog('config variable erstellt')
      infolog('Initialization finished')
   end

end
