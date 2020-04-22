class Concurrency::Future(T)

  @cached_result : Union(T | Nil)

  def self.supply(supplier : Proc(T))
    Future.new(supplier)
  end

  def self.supply_async(supplier : Proc(T))
    channel = Channel(T | Exception).new()

    spawn do
      begin
        result = supplier.call
      rescue exception
        result = exception
      end
      channel.send result
    end

    Future.supply ->() do
      result = channel.receive

      if result.is_a?(Exception)
        raise result.as(Exception)
      end

      result.as(T)
    end
  end

  def initialize(@supplier : Proc(T))
  end

  def get
    @cached_result ||= @supplier.call
  end

  def then(func : Proc(T, _))
    Future.supply ->() { func.call(self.get) }
  end

  def then_async(func : Proc(T, _))
    Future.supply_async ->() { func.call(self.get) }
  end

  def then_combine(other : Future, func : Proc(T, _, _))
    Future.supply ->() { func.call(self.get, other.get) }
  end

  def then_combine_async(other : Future, func : Proc(T, _, _))
    Future.supply_async ->() { func.call(self.get, other.get) }
  end
end
