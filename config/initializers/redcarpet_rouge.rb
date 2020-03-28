# frozen_string_literal: true

class RougeRenderer < Redcarpet::Render::HTML
  require 'rouge'
  require 'rouge/plugins/redcarpet'

  include Rouge::Plugins::Redcarpet
end

module Redcarpet
  class Pygmentize
    def self.markdown
      @markdown ||= Redcarpet::Markdown.new RougeRenderer,
                                            autolink: true,
                                            fenced_code_blocks: true,
                                            space_after_headers: true
    end

    def self.render(text)
      markdown.render(text).html_safe
    end

    def self.render_file(path)
      render File.read(path)
    end
  end
end
