module Stepable
  def steps(current_tree = tree)
    #puts "tree: #{current_tree}"

    # look for branches
    if is_branch?(current_tree)
      params = current_tree[1]

      #puts "  is a branch with params: #{params}"

      status = params["status"]
      description = params["description"]
      actionable = params["actionable"]

      # need these three params to be a step
      if status && description && actionable != nil
        #puts "    is a step"
        step = {
          :status => status,
          :description => description,
          :actionable => actionable
        }

        return [step] + steps(current_tree[2])
      else
        #puts "    is not a step"
        return steps(current_tree[2])
      end
    elsif current_tree.class == Array
      #puts "  is an array"
      sub_steps = Array.new

      current_tree.each do |node|
        sub_steps += steps(node)
      end

      return sub_steps
    else
      #puts "  is a dead end"
      return []
    end
  end

  private

  def is_branch?(current_tree)
    #puts "IN is_branch?: current_tree = #{current_tree}, size = #{current_tree.size}, element 0 is a #{current_tree[0].class}, element 1 is a #{current_tree[1].class}, element 2 is a #{current_tree[2].class}"
    return false if current_tree.size != 3

    if current_tree[0].class == String && current_tree[1].class.to_s =~ /Hash/ && current_tree[2].class == Array
      return true
    else
      return false
    end
  end
end
