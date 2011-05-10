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

  def notify(status)
    workitem = @process_status.workitems.find{|wi| wi.params["notifies"] == status}

    if workitem
      RuoteKit.engine.storage_participant.reply(workitem)

      return true
    else
      return false
    end
  end
end
