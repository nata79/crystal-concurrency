require "../spec_helper"

module Concurrency::Multiprocessing
  describe Task do
    it "parses subclasses from json" do
      my_task = MyTask.new(10, "some string")
      Task.parse_task(my_task.class_name, my_task.to_json).should eq my_task
    end
  end
end
