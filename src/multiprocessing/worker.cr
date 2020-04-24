require "./instruction"
require "./task"

module Concurrency::Multiprocessing
  class Worker
    def initialize(@work_queue : Channel(Tuple(Task, Channel(Union(String | Nil)))))
        @to_process_reader, @to_process_writer = IO.pipe(true, true)
        @to_main_reader, @to_main_writer = IO.pipe(true, true)

        @process = Process.fork { start_process_loop }
        spawn { start_inner_loop }
    end

    private def start_process_loop
        while true
            input = @to_process_reader.gets
            unless input.nil?
                instruction = Instruction.from_json(input.as(String))

                break if instruction.terminate?

                task = instruction.task
                unless task.nil?
                    result = task.as(Task).call
                    @to_main_writer.puts result.to_json
                end
            end
        end
    end

    private def start_inner_loop
        while true
            begin
                task, return_channel = @work_queue.receive
                instruction = Instruction.run_task task
                @to_process_writer.puts instruction.to_json
                Fiber.yield
                result = @to_main_reader.gets
                return_channel.send result
            rescue Channel::ClosedError
                terminate
                break
            end
        end
    end

    def terminate
        @to_process_writer.puts Instruction.terminate.to_json
    end

    def wait
        @process.wait()
    end
  end
end
