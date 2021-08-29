module ApplicationHelper
  require "redcarpet"
  require "coderay"

  # markdownをHTMLにレンダリング
  # シンタックスハイライトにcoderayで対応
  class HTMLwithCoderay < Redcarpet::Render::HTML
    def block_code(code, language)
      language = language.split(':')[0]

      case language.to_s
      when 'rb'
        lang = 'ruby'
      when 'yml'
        lang = 'yaml'
      when 'css'
        lang = 'css'
      when 'html'
        lang = 'html'
      when ''
        lang = 'md'
      else
        lang = language
      end

      CodeRay.scan(code, lang).div
    end
  end

  # markdownをHTMLにレンダリング
  def markdown(text)
    html_render = HTMLwithCoderay.new(filter_html: true, hard_wrap: true)
    options = {
      autolink: true,
      space_after_headers: true,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      tables: true,
      hard_wrap: true,
      xhtml: true,
      lax_html_blocks: true,
      strikethrough: true
    }
    markdown = Redcarpet::Markdown.new(html_render, options)
    sanitize markdown.render(text)
  end

  # 引数のファイルをmarkdownにレンダリング
  # ファイル名はプロジェクトパス
  def markdown_file(file_path)
    markdown_text = File.read(file_path)
    markdown(markdown_text)
  end
end
