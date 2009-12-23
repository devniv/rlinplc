#!/usr/bin/ruby


require 'singleton'
require 'logger'

class Log
   include Singleton

   attr_reader :file, :logger

   def initialize
      @file = "logfile.log"
      @logger = Logger.new(@file)
   end
   
end

module Logging
   def infolog(message)
      if self.class == Plugin
         @mainlogger.logger.info(self.name) { message }
      else
         @mainlogger.logger.info(self.class) { message }
      end
   end

   def warnlog(message)
      if self.class == Plugin
         @mainlogger.logger.warn(self.name) { message }
      else
         @mainlogger.logger.warn(self.class) { message }
      end
   end

   def errorlog(message)
      if self.class == Plugin
         @mainlogger.logger.error(self.name) { message }
      else
         @mainlogger.logger.error(self.class) { message }
      end
   end

   def fatallog(message)
      if self.class == Plugin
         @mainlogger.logger.fatal(self.name) { message }
      else
         @mainlogger.logger.fatal(self.class) { message }
      end
   end 

   def debuglog(message)
      if self.class == Plugin
         @mainlogger.logger.debug(self.name) { message }
      else
         @mainlogger.logger.debug(self.class) { message }
      end
   end
end
