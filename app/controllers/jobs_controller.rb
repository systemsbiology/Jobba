class JobsController < ApplicationController

  def create
    job_id = Job.start(params)

    if job_id
      render :json => {:job_id => job_id}, :status => :ok
    else
      render :json => {:message => "Workflow not found"}, :status => :unprocessable_entity
    end
  end

  def update
    job = Job.find(params[:id])

    if job
      success = job.notify(params[:status])

      if success
        render :json => {:message => "Job updated"}, :status => :ok
      else
        render :json => {:message => "No workitem responding to this status found"}, :status => :not_found
      end
    else
      render :json => {:message => "Job not found"}, :status => :not_found
    end
  end

end
