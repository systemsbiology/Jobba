class Workflow
  include Mongoid::Document
  include Stepable

  field :definition, :type => String
  field :name, :type => String

  def revision
    tree && tree[1] && tree[1]['revision']
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
