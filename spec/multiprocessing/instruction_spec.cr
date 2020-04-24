require "../spec_helper"
require "./my_task"

module Concurrency::Multiprocessing
  describe Instruction do
    it "stores serialized task and retrieves it" do
      my_task = MyTask.new(10, "some string")
      instruction = Instruction.new(Instruction::RUN_TASK, my_task)
      instruction.task.should eq my_task
    end
  end
end

