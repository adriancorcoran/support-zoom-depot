module ApplicationHelper
  
  def button_to_show(local_assigns)
    # define the properties
    use_method = local_assigns[:method] || :get
    remote = local_assigns[:remote] || false
    use_style_class = local_assigns[:style_class] ? ' ' + local_assigns[:style_class] : ''
    enabled = local_assigns[:active_button] === false ? false : true
    # set the default type to return
    type = use_method
    unless enabled
      type = :disabled
    end
    # return hash
    { type: type, use_style_class: use_style_class, text: local_assigns[:text], remote: remote }  
  end

  def get_icon_path(type)
    icons = {
      home: %{
        <path d="M19.664 8.252l-9-8a1 1 0 0 0-1.328 0L8 1.44V1a1 1 0 0 0-1-1H3a1 1 0 0 0-1 1v5.773L.336 8.252a1.001
        1.001 0 0 0 1.328 1.496L2 9.449V19a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1V9.449l.336.299a.997.997 0 0 0 1.411-.083
        1.001 1.001 0 0 0-.083-1.413zM16 18h-2v-5a1 1 0 0 0-1-1H7a1 1 0 0 0-1 1v5H4V7.671l6-5.333 6 5.333V18zm-8
        0v-4h4v4H8zM4 2h2v1.218L4 4.996V2z"></path>
      },
      products: %{
        <path d="M19 0h-9c-.265 0-.52.106-.707.293l-9 9a.999.999 0 0 0 0 1.414l9 9a.997.997 0 0 0 1.414 0l9-9A.997.997
         0 0 0 20 10V1a1 1 0 0 0-1-1zm-9 17.586L2.414 10 4 8.414 11.586 16 10 17.586zm8-8l-5 5L5.414 7l5-5H18v7.586zM15
          6a1 1 0 1 0 0-2 1 1 0 0 0 0 2"></path>
      },
      cart: %{
        <path d="M17 18c-.551 0-1-.449-1-1 0-.551.449-1 1-1 .551 0 1 .449 1 1 0 .551-.449 1-1 1zM4 17c0 .551-.449 1-1
         1-.551 0-1-.449-1-1 0-.551.449-1 1-1 .551 0 1 .449 1 1zM17.666 5.841L16.279 10H4V4.133l13.666 1.708zM17 14H4v-2h13a1
          1 0 0 0 .949-.684l2-6a1 1 0 0 0-.825-1.308L4 2.117V1a1 1 0 0 0-1-1H1a1 1 0 0 0 0 2h1v12.184A2.996 2.996 0 0 0 0
           17c0 1.654 1.346 3 3 3s3-1.346 3-3c0-.353-.072-.686-.184-1h8.368A2.962 2.962 0 0 0 14 17c0 1.654 1.346 3 3 3s3-1.346
            3-3-1.346-3-3-3z"/></path>
      },
      delete: %{
        <path d="M10 0C4.486 0 0 4.486 0 10s4.486 10 10 10 10-4.486 10-10S15.514 0 10 0m0 18c-4.411 0-8-3.589-8-8s3.589-8
         8-8 8 3.589 8 8-3.589 8-8 8m3.707-11.707a.999.999 0 0 0-1.414 0L10 8.586 7.707 6.293a.999.999 0 1 0-1.414 1.414L8.586
          10l-2.293 2.293a.999.999 0 1 0 1.414 1.414L10 11.414l2.293 2.293a.997.997 0 0 0 1.414 0 .999.999 0 0 0 0-1.414L11.414
           10l2.293-2.293a.999.999 0 0 0 0-1.414"/></path>
      }
    }
    icons[type].html_safe
  end

  def render_if(condition, record)
    if condition
      render record
    end
  end

end
