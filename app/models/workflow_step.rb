class WorkflowStep
  include Mongoid::Document
  include ActsAsList::Mongoid 

  field :name, :type => String
  field :status, :type => String
  embedded_in :workflow, :inverse_of => :workflow_steps
end
