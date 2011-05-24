require 'spec_helper'

describe JobsController do
  
  before(:each) do
    @job = mock(Job)
  end

  describe "POST 'create'" do
    it "creates a new process if the workflow is found" do
      Job.should_receive(:start).with(hash_including("workflow" => "my workflow", "title" => "stuff for bob")).
        and_return("20110524-bokobashika")

      post :create, :workflow => "my workflow", :title => "stuff for bob"

      response.status.should == 200
      JSON.parse(response.body)["job_id"].should_not be_nil
    end

    it "fails if no workflow if found" do
      Job.should_receive(:start).with(hash_including("workflow" => "nonexistent workflow", "title" => "stuff for bob")).
        and_return(nil)

      post :create, :workflow => "nonexistent workflow", :title => "stuff for bob"
      response.status.should == 422
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      # create the process
      post :create, :workflow => "my workflow", :title => "stuff for bob"
      @job_id = JSON.parse(response.body)["job_id"]
      sleep(0.1)
    end

    it "updates a process with a status notification" do
      Job.should_receive(:find).with("20110524-bokobashika").and_return(@job)
      @job.should_receive(:notify).with("hybridized").and_return(true)

      put :update, :id => "20110524-bokobashika", :participant => "slimarray", :status => "hybridized"

      response.status.should == 200
      JSON.parse(response.body)["message"].should == "Job updated"
    end

    it "returns not found status if the job doesn't exist" do
      Job.should_receive(:find).with("abcd").and_return(nil)

      put :update, :id => "abcd", :participant => "slimarray", :status => "complete"

      response.status.should == 404
      JSON.parse(response.body)["message"].should == "Job not found"
    end

    it "returns not found status if there isn't a matching workitem" do
      Job.should_receive(:find).with("20110524-bokobashika").and_return(@job)
      @job.should_receive(:notify).with("hybridized").and_return(false)

      put :update, :id => "20110524-bokobashika", :participant => "slimarray", :status => "hybridized"

      response.status.should == 404
      JSON.parse(response.body)["message"].should == "No workitem responding to this status found"
    end
  end
end
