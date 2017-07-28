require "./autolink/*"

module Autolink
  AUTO_LINK_RE = %r{
              (?: ((?:ed2k|ftp|http|https|irc|mailto|news|gopher|nntp|telnet|webcal|xmpp|callto|feed|svn|urn|aim|rsync|tag|ssh|sftp|rtsp|afs|file):)// | www\. )
              [^\s<"]+[^.$]
            }ix

  AUTO_LINK_CRE = [/<[^>]+$/, /^[^>]*>/, /<a\b.*?>/i, /<\/a>/i]

  def auto_link(text, html = {} of String => String)
    text.gsub(AUTO_LINK_RE) do |url|
      next url if auto_linked?($~.pre_match, $~.post_match)
      attrs = {"href" => url}
      attrs.merge!(html) unless html.empty?
      content_tag(:a, url, attrs)
    end
  end

  def auto_linked?(left, right)
    !!((left =~ AUTO_LINK_CRE[0] && right =~ AUTO_LINK_CRE[1]) ||
      (left.rindex(AUTO_LINK_CRE[2]) && $~.post_match !~ AUTO_LINK_CRE[3]))
  end

  def content_tag(tag, text, attributes = {} of String => String)
    "<#{tag} #{attributes.map { |(k, v)| "#{k}=\"#{v}\"" }.join(" ")}>#{text}</#{tag}>"
  end
end
