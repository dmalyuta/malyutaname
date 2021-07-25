module Jekyll
  class Figure < Liquid::Block

    def initialize(tag_name, markup, tokens)
      super
      @tags = markup
      @tags = @tags.split(" ")
    end

    def render(context)
      contents = super

      # Get the bibentry pairs
      @syntax = /^([a-z]*?)={(.*?)}/
      contents = contents.scan(@syntax)

      if contents.length() > 0 then
        # Create a dictionary of information
        info = {}
        contents.each do |item|
          info[item[0]] = item[1]
        end

        @src = info["src"]
        @alt = info["alt"]
        @caption = info["caption"]
        @width = info["width"]
        @captionwidth = info["captionwidth"]
        @label = info["label"]

        # Increment bibliography counter
        if !context["figure_counter"] then
          context["figure_counter"] = 1
        else
          context["figure_counter"] += 1
        end
        @figure_counter = context["figure_counter"]

        output = "<div class=\"figure-container\">"
        output += "<img class=\"figure-image "
        output += "figure-"+@figure_counter.to_s+"\" "
        output += "src=\"/assets/images/"+@src+"\" "
        output += "alt=\""+@alt+"\" "
        if @label then
          output += "id=\""+@label+"\" "
        end
        if @width then
          output += "width=\""+@width+"\" "
        end
        output += "/>"
        output += "<div class=\"figure-caption\" "
        if @captionwidth then
          output += "style=\"width: "+@captionwidth+";\">"
        else
          output += ">"
        end
        output += "<span class=\"figure-number\">Figure "+@figure_counter.to_s+"</span>. "
        output += @caption
        output += "</div>"
        output += "</div>"

        output
      else
        ""
      end
    end

  end

  class FigureReference < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      super
      @label = markup
    end

    def render(context)
      contents = super

      output = "<span class=\"figref\">Figure <a class=\"internal\" href=\"#"+@label+"\">"+1.to_s+"</a></span>"

      output
    end

  end
end

Liquid::Template.register_tag('figure', Jekyll::Figure)
Liquid::Template.register_tag('figref', Jekyll::FigureReference)
