class Job
  def initialize(attributes)
    @process_status = attributes[:process_status]
  end

  def self.start(params)
    workflow = Workflow.where(:name => params[:workflow]).first

    return nil unless workflow

    job_id = RuoteKit.engine.launch(
      workflow.definition, :title => params[:title],
      :details => params[:details]
    )

    return job_id
  end

  def self.find(job_id)
    process_status = RuoteKit.engine.process(job_id)

    if process_status
      return new(:process_status => process_status)
    else
      return nil
    end
  end

  def self.all
    process_statuses = RuoteKit.engine.processes.sort{|a,b| a.launched_time <=> b.launched_time}

    return process_statuses.collect{|p| Job.new(:process_status => p)}
  end

  def notify(status)
    workitem = @process_status.workitems.find{|wi| wi.params["notifies"] == status}

    if workitem
      RuoteKit.engine.storage_participant.reply(workitem)

      return true
    else
      return false
    end
  end

  def current_step
    workflow = Workflow.where(:name => @process_status.definition_name).first

    # assume a sequential process definition (1 workitem)
    workitem = @process_status.workitems.first

    if workitem
      step = workflow.workflow_steps.where(:status => workitem.params["status"]).first

      return step
    else
      return nil
    end
  end
end
