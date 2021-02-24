require_relative 'model'

class Controller
  
  attr_accessor :model

  def initialize
    @model = Model.new
  end

  def set(arrayInfo, value)
    key = arrayInfo[0]
    puts key
    flag = arrayInfo[1]
    puts flag
    expTime = arrayInfo[2]
    puts expTime
    bytes = arrayInfo[3]
    puts bytes
    return model.set(key, flag, expTime, bytes,value)
  end

end





