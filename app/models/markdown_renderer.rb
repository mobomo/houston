class MarkdownRenderer

  def self.render(content)
    options = {:autolink => true, :no_intra_emphasis => true, :strikethrough => true, :fenced_code_blocks => true, :a_parse_flag => true}

    md = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(:hard_wrap => true, :filter_html => false), options)
    md.render(content||"").html_safe
  end

end
