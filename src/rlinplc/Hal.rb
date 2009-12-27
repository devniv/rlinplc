#!/usr/bin/ruby

require 'fileutils'

module VarToS
	def to_s
	   @id + ":" + @value.to_s + " " + @unit.to_s + " busaccess: " + @busaccess.to_s + " langaccess: " + @langaccess.to_s
	end
end


class Variable
  attr_accessor :id
  attr_accessor :busaccess
  attr_accessor :langaccess
  attr_accessor :unit

  def initialize
	@id = nil
	@busaccess = nil
	@langaccess = nil
	@unit = nil
  end
  include VarToS
end

class RealVariable < Variable
  attr_accessor :value
  def initialize
    @value = 0.0
  end
end

class IntegerVariable < Variable

  attr_accessor :value

  def initialize
    @value = 0
  end

end

class BooleanVariable < Variable

  attr_accessor :value

  def initialize
    @value = false
  end

end

class ProcessImage
  include Singleton
  attr_reader :processVariable, :boleanVariables, :integerVariables, :realVariables, :config, :lang, :mainlogger

  include Logging

  def initialize
        @mainlogger = Log.instance
        config = RlinConfig.instance
	@booleanVariables = Array.new
	@integerVariables = Array.new
	@realVariables = Array.new
	config.variables.each do |h|
	   v = initVariables(h['type'], h['id'], h['busaccess'], h['langaccess'], h['unit'])
	end
	Dir["rlinplc/plugins/*.rb"].each{|x| load x }
	debuglog("loaded plugins")
	infolog("Initialization finished")
  end
 
  def inithelper
     infolog("creating my own config file")
     @config = {}
     @config['lang'] = 'ruby'
     @config['variables'] = Array.new(5) { Hash.new }
     @config['variables'][0]['type'] = "IntegerVariable"
     @config['variables'][0]['id'] = "track"
     @config['variables'][1]['type'] = "IntegerVariable"
     @config['variables'][1]['id'] = "mode"
     @config['variables'][2]['type'] = "IntegerVariable"
     @config['variables'][2]['id'] = "playlist"
     @config['variables'][3]['type'] = "RealVariable"
     @config['variables'][3]['id'] = "remaining_time"
     @config['variables'][4]['type'] = "BoolVariable"
     @config['variables'][4]['id'] = "audio_data"
     @config['input'] = {}
     @config['input']['plugin'] = "txtfile"
     @config['input']['parameter'] = "input.txt"
     @config['output'] = {}
     @config['output']['plugin'] = "txtfile"
     @config['output']['parameter'] = "output.txt"
     saveConfig
     infolog("Finished creating own config file")
  end

  def initVariables(type, id, busaccess = nil, langaccess = nil, unit = nil)
    case type
       when "IntegerVariable" then 
         v =  IntegerVariable.new 
	 v.id = id 
	 v.busaccess = busaccess
	 v.langaccess = langaccess
	 v.unit = unit
	 @integerVariables << v
       when "RealVariable" then
         v = RealVariable.new 
	 v.id = id 
	 v.busaccess = busaccess
	 v.langaccess = langaccess
	 v.unit = unit
	 @realVariables << v
       when "BoolVariable" then 
         v = BooleanVariable.new 
	 v.id = id 
	 v.busaccess = busaccess
	 v.langaccess = langaccess
	 v.unit = unit
	 @booleanVariables << v 
       else "error"  
    end
    debuglog("Finished initVariables")
  end

  def printStatus

    puts "Process Image Status: "
    puts "IntegerVariablen:"
    puts @integerVariables
    puts "RealVariablen"
    puts @realVariables
    puts "BooleanVariablen"
    puts @booleanVariables
    puts 
  end

  def ioget(varname)
    @booleanVariables.each do |h|
    if varname == h.id and h.busaccess.include? "r"
       return h
    end
  end
    @integerVariables.each do |h|
    if varname == h.id and h.busaccess.include? "r"
       return h
    end
  end
    @realVariables.each do |h|
    if varname == h.id and h.busaccess.include? "r"
       return h
    end
  end
  end

  def langget(varname)
    @booleanVariables.each do |h|
    if varname == h.id and h.langaccess.include? "r"
       return h
    end
  end
    @integerVariables.each do |h|
    if varname == h.id and h.langaccess.include? "r"
       return h
    end
  end
    @realVariables.each do |h|
    if varname == h.id and h.langaccess.include? "r"
       return h
    end
  end
  end
  
  def ioset(varname, varvalue)
    @booleanVariables.each do |h|
      if varname == h.id and h.busaccess.include? "w"
         h.value = varvalue
      end
    end
    @integerVariables.each do |h|
      if varname == h.id and h.busaccess.include? "w"
         h.value = varvalue
      end
    end
    @realVariables.each do |h|
      if varname == h.id and h.busaccess.include? "w"
         h.value = varvalue
      end
    end
  end
  
  def langset(varname, varvalue)
    @booleanVariables.each do |h|
      if varname == h.id and h.langaccess.include? "w"
         h.value = varvalue
      end
    end
    @integerVariables.each do |h|
      if varname == h.id and h.langaccess.include? "w"
         h.value = varvalue
      end
    end
    @realVariables.each do |h|
      if varname == h.id and h.langaccess.include? "w"
         h.value = varvalue
      end
    end
  end

  def iotoggle(varname)
    var = ioget(varname)
    debuglog "#{var.id} geholt"
    if var.class.to_s == "BooleanVariable"
      if var.value == true
         ioset(varname, false)
      else
         ioset(varname, true)
      end
    end
 end
 
 def saveConfig
     File.open('config.yml', 'w') { |f| f.write(@config.to_yaml) }
     debuglog("Finished saving config")
  end
end
