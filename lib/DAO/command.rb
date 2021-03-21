class Command

  attr_accessor :key, :flag, :time, :bytes, :value, :cas_value, :exp_time

  def initialize(key, flag, exp_time, bytes, value, cas_value)
    @key = key
    @flag = flag
    @exp_time = exp_time
    @bytes = bytes
    @value = value
    @cas_value = cas_value
  end

end
