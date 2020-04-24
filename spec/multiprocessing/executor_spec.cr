require "../spec_helper"
require "./my_task"

module Concurrency::Multiprocessing
  describe Executor do
    it "runs a task in a process and returns the result wrapped in a future" do
      my_task = MyTask.new(10, "some string")
      executor = Executor(MyResult).new(2)

      future = executor.run(my_task)

      future.get.should eq MyResult.new(10, "some string")

      executor.terminate()
    end
  end
end

