require "json"

class MyTask < Concurrency::Multiprocessing::Task

  getter :num
  getter :str

  def initialize(@num : Int32, @str : String)
  end

  def ==(other : self)
    other.num == self.num && other.str == self.str
  end

  def call
    raise Exception.new if @str == "exception"
    MyResult.new(@num, @str)
  end
end

class MyResult
  include JSON::Serializable

  getter :num
  getter :str

  def initialize(@num : Int32, @str : String)
  end

  def ==(other : self)
    other.num == self.num && other.str == self.str
  end
end
