class Job
  extend ActiveSupport::Memoizable

  # use class << self to easily memoize class methods
  class << self
    extend ActiveSupport::Memoizable

    def start(params)
      workflow = Workflow.where(:name => params[:workflow]).first

      return nil unless workflow

      job_id = RuoteKit.engine.launch(
        workflow.definition, {}, {:title => params[:title], :details => params[:details]}
      )

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

    memoize :all
  end

  def initialize(attributes)
    @process_status = attributes[:process_status]
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

  def title
    @process_status.variables["title"]
  end

  def details
    @process_status.variables["details"]
  end

  def as_json(options = {})
    {
      :id => id,
      :title => title,
      :details => details,
      :current_step => current_step.name,
      :steps => workflow.workflow_steps.collect do |step|
        {
          :name => step.name,
          :description => step.description,
          :actionable => step.actionable
        }
      end
    }
  end

  memoize :workflow
end
