require 'spec_helper'

describe JobsController do
  
  before(:each) do
    definition = 
      "Ruote.process_definition :name => 'test', :revision => '0.1' do
        sequence do
          slimarray :notifies => 'hybridized', :status => 'submitted'
          slimarray :notifies => 'complete', :status => 'hybridized'
          staff_notification :message => 'Data Ready'
          staff :workflow => 'Email User', :status => 'extracted'
        end
      end"

    @workflow = Workflow.create(:name => "my workflow", :definition => definition)
  end

  describe "POST 'create'" do
    it "creates a new process if the workflow is found" do
      post :create, :workflow => "my workflow", :title => "stuff for bob"

      response.status.should == 200
      JSON.parse(response.body)["job_id"].should_not be_nil
    end

    it "fails if no workflow if found" do
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
      put :update, :id => @job_id, :participant => "slimarray", :status => "hybridized"

      sleep(0.1)
      RuoteKit.engine.process(@job_id).workitems.first.params["status"].should == "hybridized"
    end

    it "returns not found status if the job doesn't exist" do
      put :update, :id => @job_id, :participant => "slimarray", :status => "complete"
      response.status.should == 404

      sleep(0.1)
      RuoteKit.engine.process(@job_id).workitems.first.params["status"].should == "submitted"
    end

    it "returns not found status if there isn't a matching workitem" do
      put :update, :id => "abcd", :participant => "slimarray", :status => "hybridized"
      response.status.should == 404

      sleep(0.1)
      RuoteKit.engine.process(@job_id).workitems.first.params["status"].should == "submitted"
    end
  end
end
