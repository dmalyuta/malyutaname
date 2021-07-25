module Jekyll
  class NavigationItem < Liquid::Tag
    def initialize(tagName, markup, tokens)
      super
      @text = markup
    end

    def render(context)
      output = '<span class="article-subnav-item">'+@text+'</span>'
      output
    end
  end
end

Liquid::Template.register_tag('navitem', Jekyll::NavigationItem)
