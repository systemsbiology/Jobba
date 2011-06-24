require 'spec_helper'

describe Job do
  before(:each) do
    definition = 
      "Ruote.process_definition :name => 'my workflow', :revision => '0.1' do
        sequence do
          slimarray :status => 'submitted', :description => 'Waiting for SLIMarray hybridization', :actionable => false
          slimarray :status => 'hybridized', :description => 'Waiting for raw data to go into SLIMarray', :actionable => false
          staff_notification :message => 'Data Ready'
          staff :status => 'extracted', :description => 'Prepare data, notify user', :actionable => true
          staff :status => 'completed', :description => 'Clear job', :actionable => false
        end
      end"

    @workflow = Workflow.create(:name => "my workflow", :definition => definition)
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

    Job.find(job_id).current_step.should == {:status => 'submitted', :description => 'Waiting for SLIMarray hybridization', :actionable => false}
  end

  it "provides a sorted list of all jobs" do
    job_id_1 = Job.start(:workflow => "my workflow", :title => "stuff for bob", :details => "not important")
    job_id_2 = Job.start(:workflow => "my workflow", :title => "stuff for bob", :details => "not important")
    job_id_3 = Job.start(:workflow => "my workflow", :title => "stuff for bob", :details => "not important")

    Job.all.size.should == 3
  end

  it "has a workflow" do
    job_id = Job.start(:workflow => "my workflow", :title => "stuff for bob", :details => "not important")
    job = Job.find(job_id)
    
    job.workflow.should == @workflow
  end

  it "has an id" do
    job_id = Job.start(:workflow => "my workflow", :title => "stuff for bob", :details => "not important")
    job = Job.find(job_id)

    job.id.should == job_id
  end

  it "has a title" do
    job_id = Job.start(:workflow => "my workflow", :title => "stuff for bob", :details => "not important")
    job = Job.find(job_id)

    job.title.should == "stuff for bob"
  end

  it "has details" do
    job_id = Job.start(:workflow => "my workflow", :title => "stuff for bob", :details => "not important")
    job = Job.find(job_id)

    job.details.should == "not important"
  end

  it "provides a JSON representation" do
    job_id = Job.start(:workflow => "my workflow", :title => "stuff for bob", :details => "not important")
    job = Job.find(job_id)

    job.as_json.should == {
      :id => job_id,
      :title => "stuff for bob",
      :details => "not important",
      :current_step => "submitted",
      :steps => [
        {:status => "submitted", :description => "Waiting for SLIMarray hybridization", :actionable => false},
        {:status => "hybridized", :description => "Waiting for raw data to go into SLIMarray", :actionable => false},
        {:status => "extracted", :description => "Prepare data, notify user", :actionable => true},
        {:status => "completed", :description => "Clear job", :actionable => false}
      ]
    }
  end
end
