module Stepable
  def steps(current_tree = tree)

    # look for branches
    if is_branch?(current_tree)
      params = current_tree[1]

      status = params["status"]
      description = params["description"]
      actionable = params["actionable"]

      # need these three params to be a step
      if status && description && actionable != nil
        step = {
          :status => status,
          :description => description,
          :actionable => actionable
        }

        return [step] + steps(current_tree[2])
      else
        return steps(current_tree[2])
      end
    elsif current_tree.class == Array
      sub_steps = Array.new

      current_tree.each do |node|
        sub_steps += steps(node)
      end

      return sub_steps
    else
      return []
    end
  end

  private

  def is_branch?(current_tree)
    return false if current_tree.size != 3

    if current_tree[0].class == String && current_tree[1].class.to_s =~ /Hash/ && current_tree[2].class == Array
      return true
    else
      return false
    end
  end
end
