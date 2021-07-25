module Jekyll
  class Footnote < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      super
      @tags = markup
    end

    def render(context)
      contents = super

      # Get the footnote count
      if !context["footnote_count"] then
        context["footnote_count"] = 1
      else
        # Update footnote counter
        context["footnote_count"] += 1
      end
      @footnote_count = context["footnote_count"]

      # Generate the footnote
      footnote = "<span class=\"footnote-text-all\" id=\"footnote-"+
                 @footnote_count.to_s+"\">";
      footnote += "<span class=\"footnote-number\"><sup>"+
                  @footnote_count.to_s+"</sup></span>"
      footnote += "<span class=\"footnote-text\">"+@tags+"</span>"
      footnote += "</span>";

      # Generate the footnote mark
      footnote_mark = "<sup><a href=\"#footnote-"+@footnote_count.to_s+"\" "+
                      "class=\"internal footnote-mark\">"+
                      @footnote_count.to_s+"</a></sup>"

      output = footnote_mark+footnote;

      output
    end

  end
end

Liquid::Template.register_tag('footnote', Jekyll::Footnote)
