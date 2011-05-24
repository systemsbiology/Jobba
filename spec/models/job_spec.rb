require 'spec_helper'

describe Job do
  
  before(:each) do
    definition = 
      "Ruote.process_definition :name => 'my workflow', :revision => '0.1' do
        sequence do
          slimarray :notifies => 'hybridized', :status => 'submitted'
          slimarray :notifies => 'complete', :status => 'hybridized'
          staff_notification :message => 'Data Ready'
          staff :workflow => 'Email User', :status => 'extracted'
        end
      end"

    @workflow = Workflow.create(:name => "my workflow", :definition => definition)
    @step_1 = @workflow.workflow_steps.create(:name => "Submitted", :status => "submitted")
    @step_2 = @workflow.workflow_steps.create(:name => "Hybridized", :status => "hybridized")
    @step_3 = @workflow.workflow_steps.create(:name => "Extracted", :status => "extracted")
    @step_4 = @workflow.workflow_steps.create(:name => "Complete", :status => "complete")
  end

  it "starts a job if a workflow is found" do
    job_id = Job.start(:workflow => "my workflow", :title => "stuff for bob", :details => "not important")

    job_id.should_not be_nil
  end

  it "doesn't start a job if a workflow isn't found" do
    job_id = Job.start(:workflow => "nonexistent workflow", :title => "stuff for bob", :details => "not important")

    job_id.should be_nil
  end

  describe "finding a job" do
    before(:each) do
      @job_id = Job.start(:workflow => "my workflow", :title => "stuff for bob", :details => "not important")
      sleep 0.1
    end

    it "finds a job by the job_id" do
      job = Job.find(@job_id)
      job.should_not be_nil
    end

    it "doesn't find a job with a bogus job_id" do
      job = Job.find("20110510-bababa")
      job.should be_nil
    end
  end

  describe "receiving a notification" do
    before(:each) do
      job_id = Job.start(:workflow => "my workflow", :title => "stuff for bob", :details => "not important")
      sleep 0.1
      @job = Job.find(job_id)
    end

    it "advances the job when there's a workitem waiting for the notification" do
      @job.notify("hybridized").should be_true
    end

    it "does nothing if there isn't a workitem that responds" do
      @job.notify("completed").should be_false
    end
  end

  it "provides the current step" do
    job_id = Job.start(:workflow => "my workflow", :title => "stuff for bob", :details => "not important")
    sleep 0.1

    Job.find(job_id).current_step.should == @step_1
  end

  it "provides a sorted list of all jobs" do
    job_id_1 = Job.start(:workflow => "my workflow", :title => "stuff for bob", :details => "not important")
    job_id_2 = Job.start(:workflow => "my workflow", :title => "stuff for bob", :details => "not important")
    job_id_3 = Job.start(:workflow => "my workflow", :title => "stuff for bob", :details => "not important")
    sleep 0.1

    Job.all.size.should == 3
  end

  it "has a workflow" do
    job_id = Job.start(:workflow => "my workflow", :title => "stuff for bob", :details => "not important")
    sleep 0.1
    job = Job.find(job_id)
    
    job.workflow.should == @workflow
  end

  it "has an id" do
    job_id = Job.start(:workflow => "my workflow", :title => "stuff for bob", :details => "not important")
    sleep 0.1
    job = Job.find(job_id)
    job.id.should == job_id
  end
end