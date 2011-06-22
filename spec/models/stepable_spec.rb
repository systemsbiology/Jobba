require 'spec_helper'

class Example
  include Stepable

  def tree
    ["define", {"name"=>"slimarray samples", "revision"=>"0.1"}, [["sequence", {}, [["participant", {"status"=>"submitted", "description"=>"waiting for hyb", "actionable"=>false, "ref"=>"slimarray"}, []], ["slimarray", {"status"=>"hybridized", "description"=>"waiting for data", "actionable"=>false}, []], ["staff_notification", {"message"=>"Data Ready"}, []], ["staff", {"workflow"=>"Email User", "status"=>"extracted", "description"=>"process data, email user", "actionable"=>true}, []], ["participant", {"status"=>"completed", "description"=>"done", "actionable"=>false}, []]]]]]
  end
end

describe Stepable do
  it "extracts the steps from a tree" do
    example = Example.new
    example.steps.should == [
      {:status => "submitted", :description => "waiting for hyb", :actionable => false},
      {:status => "hybridized", :description => "waiting for data", :actionable => false},
      {:status => "extracted", :description => "process data, email user", :actionable => true},
      {:status => "completed", :description => "done",  :actionable => false}
    ]
  end
end
