module Jekyll
  def self.render_math(latex_code, displaystyle)
    output = "<script>"
    output += "var math_string = katex.renderToString(String.raw`"
    output += latex_code
    output += "`, {"
    if displaystyle then
      output += "displayMode: true,"
    end
    output += 'globalGroup: true,'
    output += 'throwOnError: false,'
    output += 'trust: ["\\\\htmlClass"],'
    output += 'strict: false,'
    output += 'macros: {'
    if displaystyle then
      output += '"\\\\label": String.raw`\\htmlClass{#1 equation-#2 eqlabel}{}`,'
    end
    output += '"\\\\T": String.raw`^{\\scriptscriptstyle{\\mathsf{T}}}`,'
    output += '"\\\\grad": String.raw`\\nabla`,'
    output += '}'
    output += "});"
    output += "document.write('<span class=\""
    output += displaystyle ? "display" : "inline"
    output += "-equation\">'"
    output += "+math_string+"
    output += "'</span>');"
    output += "</script>"

    output
  end

  def self.render_eqref(reference)
    output = "(<a href=\"#"+reference+"\" "
    output += "class=\""+reference+" eqreflink internal\">"
    output += "<b>??</b>"
    output += "</a>)"
    output
  end

  class Equation < Liquid::Block

    def initialize(tag_name, markup, tokens)
      super
      @tags = markup
      @tags = @tags.split(" ")
    end

    def render(context)
      contents = super
      @@displaystyle = @tags.include? 'display'
      Jekyll::render_math(contents, @@displaystyle)
    end

  end

  class LatexMathMode < Liquid::Block
    MATH_PATTERN = /(\$)(.+?)\1/m.freeze
    EQREF_PATTERN = /\\eqref{(.+?)}/m.freeze

    def initialize(tag_name, markup, tokens)
      super
    end

    def render(context)
      contents = super
      rendered_str = contents.to_s.gsub(MATH_PATTERN) do |match|
        Jekyll::render_math(Regexp.last_match(2), false)
      end
      rendered_str = rendered_str.to_s.gsub(EQREF_PATTERN) do |match|
        Jekyll::render_eqref(Regexp.last_match(1))
      end
      rendered_str
    end
  end

  class EquationReference < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @tags = markup.split(" ")
      @ref = @tags[0]
    end

    def render(context)
      Jekyll::render_eqref(@ref)
    end
  end
end

Liquid::Template.register_tag('latex', Jekyll::Equation)
Liquid::Template.register_tag('latexmm', Jekyll::LatexMathMode)
Liquid::Template.register_tag('eqref', Jekyll::EquationReference)
