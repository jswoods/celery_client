require 'rubygems'
require 'json'


module CeleryClient
  class TaskManager
    def initialize(connection, wait=true, timeout=60, verbose=false)
      @connection = connection
      @timeout = Integer(timeout)
      @tasks = {}
      @wait = wait
      if @wait.is_a?(String)
        @wait = to_boolean(@wait)
      end
      @verbose = verbose
      if @verbose.is_a?(String)
        @verbose = to_boolean(@verbose)
      end
    end

    def run(context, task_name, params)
      if @verbose
        puts "Executing #{context}/#{task_name} with payload #{params}" 
      end
      result = @connection.post(
        get_run_path(context, task_name), params)
      task_id = get_task_id(result)
      save_task(task_id, context, task_name, params)
      task_id
    end

    def status(task_id)
      check_task(task_id)
      check_for_status(task_id)
    end

    def result(task_id)
      check_task(task_id)
      check_for_result(task_id)
    end

    private

    def to_boolean(string)
      !!(string =~ /^(true|t|yes|y|1)$/i)
    end

    def check_task(task_id)
      counter = 0
      while true
        response = @connection.get(
          get_status_path(get_context(task_id), task_id))
        status = get_task_status(response)
        set_status(task_id, status)
        set_result(task_id, get_task_result(response))
        if not @wait or counter >= @timeout or status != 'PENDING'
          break
        end
        if @verbose
          puts "Current status is #{status}"
        end
        sleep 1
        counter += 1
      end
    end

    def get_run_path(context, task_name)
      "/#{context}/manage/apply/#{task_name}"
    end

    def get_status_path(context, task_id)
      "/#{context}/manage/status/#{task_id}"
    end

    def get_task_id(result)
      get_task_key(result, 'task_id')
    end

    def get_task_result(result)
      get_task_key(result, 'result')
    end

    def get_task_status(result)
      get_task_key(result, 'status')
    end

    def get_task_key(result, key)
      results = JSON.parse(result)
      begin
        value = results.fetch('task').fetch(key)
      rescue KeyError
        begin
          value = results.fetch(key)
        rescue KeyError
          abort("Unable to get #{key} from task. Got this instead: #{result}.")
        end
      end
      value
    end

    def get_context(task_id)
      begin
        context = check_for_task(task_id).fetch(:context) 
      rescue KeyError
        abort("No context for task: #{task_id}")
      end
      context
    end

    def set_status(task_id, status)
      @tasks[task_id][:data][:status] = status
    end

    def set_result(task_id, result)
      @tasks[task_id][:data][:result] = result
    end

    def save_task(task_id, context, task_name, params)
      @tasks[task_id] = {:context => context, :task_name => task_name, :params => params, :data => {}}
    end

    def check_for_task(task_id)
      begin
        return @tasks.fetch(task_id)
      rescue KeyError
        abort("No task: #{task_id}")
      end
    end

    def check_for_status(task_id)
      begin
        return check_for_task(task_id).fetch(:data).fetch(:status)
      rescue KeyError
        abort("No status for task: #{task_id}")
      end
    end

    def check_for_result(task_id)
      begin
        return @tasks.fetch(task_id).fetch(:data).fetch(:result)
      rescue KeyError
        abort("No result for task: #{task_id}")
      end
    end
  end
end
