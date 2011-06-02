require 'spec_helper'

describe Workflow do
  before(:each) do
    definition = 
      "Ruote.process_definition :name => 'my workflow', :revision => '0.1' do
        sequence do
          slimarray :notifies => 'hybridized', :status => 'submitted'
          slimarray :notifies => 'complete', :status => 'hybridized'
          staff_notification :message => 'Data Ready'
          staff :action => 'Email User', :status => 'extracted'
        end
      end"

    @workflow = Workflow.create(:definition => definition)
  end

  it "has a name" do
    @workflow.name.should == "my workflow"
  end

  it "has a revision" do
    @workflow.revision.should == "0.1"
  end
end
