module ApplicationHelper
  
  def button_to_show(local_assigns)
    # define the properties
    use_method = local_assigns[:method] || :get
    use_style_class = local_assigns[:style_class] ? ' ' + local_assigns[:style_class] : ''
    enabled = local_assigns[:active_button] === false ? false : true
    # set the default type to return
    type = use_method
    unless enabled
      type = :disabled
    end
    # return hash
    { :type => type, :use_style_class => use_style_class, :text => local_assigns[:text] }  
  end

end
