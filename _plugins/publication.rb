module Jekyll
  class Publication < Liquid::Block

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

        @authors = info["authors"]
        @title = info["title"]
        @venue = info["venue"]
        @year = info["year"]
        @arxiv = info["arxiv"]
        @researchgate = info["researchgate"]
        @openreview = info["openreview"]
        @github = info["github"]
        @award = info["award"]

        # Highlight my name
        @authors["D. Malyuta"] = "<b>D. Malyuta</b>"

        # Increment bibliography counter
        if @tags.include? "reset" then
          context["counter"] = 1
        else
          context["counter"] += 1
        end

        output = "<div class=\"bibentry\">"
        output += "<div class=\"bibentry-counter\">"
        output += "[#{context["counter"]}]"
        output += "</div>"
        output += "<div class=\"bibentry-content\">"
        output += "<div class=\"bibentry-text\">"
        output += "#{@authors}, \"#{@title},\" <i>#{@venue}</i>, #{@year}."
        output += "</div>"
        if @arxiv or @github or @researchgate or @openreview then

          prefix = {"arxiv"=>"PDF",
                    "researchgate"=>"PDF",
                    "openreview"=>"PDF",
                    "github"=>"Code"}

          output += "<div class=\"bibentry-links\">"
          ["arxiv", "researchgate", "openreview", "github"].each do |kind|
            if !info[kind] then
              next
            end
            output += "<span class=\"bibentry-link-entry\">"
            output += "<span class=\"bibentry-link-entry-text\">"
            output += "#{prefix[kind]}:"
            output += "</span>"
            if kind=="arxiv" then
              output += "<a class=\"#{kind}\" "\
                        "href=\"https://arxiv.org/abs/#{info[kind]}\"" \
                        "target=\"_blank\" rel=\"noopener noreferrer\">" \
                        "arXiv.org</a>"
            elsif kind=="researchgate"
              output += "<a class=\"#{kind}\" "\
                        "href=\"https://www.researchgate.net/publication/#{info[kind]}\"" \
                        "target=\"_blank\" rel=\"noopener noreferrer\">" \
                        "<i class=\"fab fa-researchgate\"></i></a>"
            elsif kind=="openreview"
              output += "<a class=\"#{kind}\" "\
                        "href=\"https://openreview.net/forum?id=#{info[kind]}\"" \
                        "target=\"_blank\" rel=\"noopener noreferrer\">" \
                        "OpenReview<span class=\"openreview-net\">.net</span></i></a>"
            elsif kind=="github"
              output += "<a class=\"#{kind}\" "\
                        "href=\"https://github.com/#{info[kind]}\"" \
                        "target=\"_blank\" rel=\"noopener noreferrer\">" \
                        "<i class=\"fab fa-github-square\"></i></a>"
            end
            output += "</span>"
          end
          output += "</div>"
        end
        if @award then
          output += "<div class=\"bibentry-award\">"
          output += "<span class=\"bibentry-award-textarea\">"
          output += "<i class=\"fas fa-trophy\"></i> #{@award}"
          output += "</span>"
          output += "</div>"
        end
        output += "</div>"
        output += "</div>"

        output
      else
        ""
      end
    end

  end
end

Liquid::Template.register_tag('publication', Jekyll::Publication)
