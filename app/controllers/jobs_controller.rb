class JobsController < ApplicationController

  def create
    workflow = Workflow.where(:name => params[:workflow]).first

    if workflow
      wfid = RuoteKit.engine.launch(
        workflow.definition, :title => params[:title],
        :details => params[:details]
      )
      render :json => {:wfid => wfid}, :status => :ok
    else
      render :json => {:message => "Workflow not found"}, :status => :unprocessable_entity
    end
  end

  def update
    wfid = params[:id]
    process_status = RuoteKit.engine.process(wfid)

    if process_status
      workitem = process_status.workitems.find{|wi| wi.params["notifies"] == params[:status]}

      if workitem
        RuoteKit.engine.storage_participant.reply(workitem)
        render :json => {:message => "Job updated"}, :status => :ok
      else
        render :json => {:message => "No workitem responding to this status found"}, :status => :not_found
      end
    else
      render :json => {:message => "Job not found"}, :status => :not_found
    end
  end

end
