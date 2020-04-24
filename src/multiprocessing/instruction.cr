require "json"
require "./task"

module Concurrency::Multiprocessing
  class Instruction
    include JSON::Serializable

    TERMINATE = "terminate"
    RUN_TASK = "run_task"

    @instruction_type : String
    @task_type_name : Union(String | Nil)
    @serialized_task : Union(String | Nil)

    getter :instruction_type

    def self.terminate
      new(TERMINATE, nil)
    end

    def self.run_task(task)
      new(RUN_TASK, task)
    end

    def initialize(@instruction_type : String, task : Union(Task | Nil))
        unless task.nil?
            @task_type_name = task.class_name
            @serialized_task = task.to_json
        end
    end

    def task
        unless @task_type_name.nil? || @serialized_task.nil?
            Task.parse_task @task_type_name.as(String), @serialized_task.as(String)
        end
    end

    def terminate?
        @instruction_type == TERMINATE
    end
  end
end
