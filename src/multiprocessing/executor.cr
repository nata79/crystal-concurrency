require "./instruction"
require "./task"
require "./worker"
require "../future"

module Concurrency::Multiprocessing
  class Executor(T)

    @workers : Array(Worker)

    def initialize(num_workers : UInt8, buffer_size : Int32 = 10)
        @channel = Channel(Tuple(Task, Channel(Union(String | Nil)))).new(buffer_size)
        @workers = (0..num_workers).map { Worker.new(@channel) }
    end

    def run(task : Task)
        return_channel = Channel(Union(String | Nil)).new(1)
        @channel.send({task, return_channel})

        Future.supply(->() { return_channel.receive })
          .then(->(data : Union(String | Nil)) { data.nil? ? nil : T.from_json(data.as(String)) })
    end

    def terminate
        @channel.close
        @workers.each { |worker| worker.wait() }
    end
  end
end
