class Workflow
  include Mongoid::Document

  # Note that this name must match the name in the process definition
  field :name, :type => String

  field :definition, :type => String
  embeds_many :workflow_steps

  def revision
    tree[1]['revision']
  end

  def tree
    Ruote::Reader.read(definition)
  end

  def tree_json
    Rufus::Json.encode(tree)
  end

  # Makes sure the definition contains a string that is Ruby code.
  #
  def rubyize!
    self.definition = Ruote::Reader.to_ruby(tree).strip
  end
end
