module ProductsHelper
  def formatted_description(description)
    truncate(strip_tags(description), length: 140)
  end
end
