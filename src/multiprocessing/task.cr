require "json"

module Concurrency::Multiprocessing
  class Task
    include JSON::Serializable

    PARSERS = {} of String => Proc(String, Task)

    def self.track_subclass(type_name : String, parser : Proc)
        PARSERS[type_name] = parser
    end

    def self.parse_task(type_name, data)
        return PARSERS[type_name].call(data)
    end

    macro inherited
        parser = Proc(String, Concurrency::Multiprocessing::Task).new { |data| {{@type}}.from_json(data) }
        Concurrency::Multiprocessing::Task.track_subclass({{@type.stringify}}, parser)

        def class_name
            {{@type.stringify}}
        end
    end

    def class_name
        "Task"
    end

    def call
    end
  end
end
