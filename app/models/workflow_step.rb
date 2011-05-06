class WorkflowStep
  include Mongoid::Document
  include ActsAsList::Mongoid 

  field :task_id, :type => Integer
  field :name, :type => String
  field :status, :type => String
  embedded_in :workflow, :inverse_of => :task_steps
end
