class Job
  include Stepable

  class << self
    def start(params)
      workflow = Workflow.where(:name => params[:workflow]).first

      return nil unless workflow

      job_id = RuoteKit.engine.launch(
        workflow.definition, {}, {:title => params[:title], :details => params[:details]}
      )

      # give a job 30 seconds to start
      Timeout.timeout 30 do
        process_status = RuoteKit.engine.process(job_id)

        until(process_status)
          sleep 0.1
          process_status = RuoteKit.engine.process(job_id)
        end
      end

      return job_id
    end

    def find(job_id)
      process_status = RuoteKit.engine.process(job_id)

      if process_status
        return new(:process_status => process_status)
      else
        return nil
      end
    end

    def all
      process_statuses = RuoteKit.engine.processes.sort{|a,b| a.launched_time <=> b.launched_time}

      return process_statuses.collect{|p| Job.new(:process_status => p)}
    end
  end

  def initialize(attributes)
    @process_status = attributes[:process_status]
  end

  def notify(status)
    # find the step being specified
    step = steps.find{|s| s[:status] == status}
    step_index = steps.index(step)

    # then see if we're currently on the prior step
    previous_step = steps[step_index - 1]
    workitem = @process_status.workitems.find{|wi| wi.params["status"] == previous_step[:status]}

    if workitem
      RuoteKit.engine.storage_participant.reply(workitem)

      return true
    else
      return false
    end
  end

  def current_step
    # assume a sequential process definition (1 workitem)
    workitem = @process_status.workitems.first
    return nil unless workitem

    step = steps.find{|s| s[:status] == workitem.params["status"]}

    return step
  end

  def workflow
    Workflow.where(:name => @process_status.definition_name).first
  end

  def id
    @process_status.wfid
  end

  def title
    @process_status.variables["title"]
  end

  def details
    @process_status.variables["details"]
  end

  def tree
    @process_status.current_tree
  end

  def as_json(options = {})
    {
      :id => id,
      :title => title,
      :details => details,
      :current_step => current_step[:status],
      :steps => steps
    }
  end
end
