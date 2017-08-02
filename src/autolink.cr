require "./autolink/*"

module Autolink
  AUTO_LINK_RE = %r{
              (?: ((?:ed2k|ftp|http|https|irc|mailto|news|gopher|nntp|telnet|webcal|xmpp|callto|feed|svn|urn|aim|rsync|tag|ssh|sftp|rtsp|afs|file):)// | www\. )
              [^\s<\"]+[^.<$]
            }ix

  AUTO_LINK_CRE = [/<[^>]+$/, /^[^>]*>/, /<a\b.*?>/i, /<\/a>/i]

  BRACKETS = {"]" => "[", ")" => "(", "}" => "{"}

  extend self

  def auto_link(text, html = {} of String => String)
    text.gsub(AUTO_LINK_RE) do |url|
      next url if auto_linked?($~.pre_match, $~.post_match)

      punctuation = [] of String
      while (url =~ /[^\p{L}\/-=&]$/)
        punctuation << $~[0]
        opening = BRACKETS[punctuation.last]?
        if opening && url.scan(opening).size >= url.scan(punctuation.last).size
          punctuation.pop
          break
        else
          url = $~.pre_match
        end
      end

      attrs = {"href" => url}
      attrs.merge!(html) unless html.empty?
      content_tag(:a, url, attrs) + punctuation.reverse.join("")
    end
  end

  def auto_linked?(left, right)
    return true if (left =~ AUTO_LINK_CRE[0] && right =~ AUTO_LINK_CRE[1])
    if left.match(AUTO_LINK_CRE[2]) && left.rindex(AUTO_LINK_CRE[2])
      return $~.post_match !~ AUTO_LINK_CRE[3]
    end
    false
  end

  def content_tag(tag, text, attributes = {} of String => String)
    "<#{tag} #{attributes.map { |(k, v)| "#{k}=\"#{v}\"" }.join(" ")}>#{text}</#{tag}>"
  end
end
