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
    # assume a sequential process definition (1 workitem)
    workitem = @process_status.workitems.first
    return nil unless workitem && workflow

    step = workflow.workflow_steps.where(:status => workitem.params["status"]).first

    return step
  end

  def workflow
    Workflow.where(:name => @process_status.definition_name).first
  end

  def id
    @process_status.wfid
  end

  def as_json(options = {})
    {
      :id => id,
      :current_step => current_step.name,
      :actionable => current_step.actionable,
      :steps => workflow.workflow_steps.collect{|s| s.name}
    }
  end
end
