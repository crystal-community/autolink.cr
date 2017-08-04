require "./spec_helper"
require "html"
require "markdown"

describe Autolink do
  it "auto link URLs" do
    urls = %w(
      http://www.rubyonrails.com
      http://www.rubyonrails.com:80
      http://www.rubyonrails.com/~minam
      https://www.rubyonrails.com/~minam
      http://www.rubyonrails.com/~minam/url%20with%20spaces
      http://www.rubyonrails.com/foo.cgi?something=here
      http://www.rubyonrails.com/foo.cgi?something=here&and=here
      http://www.rubyonrails.com/contact;new
      http://www.rubyonrails.com/contact;new%20with%20spaces
      http://www.rubyonrails.com/contact;new?with=query&string=params
      http://www.rubyonrails.com/~minam/contact;new?with=query&string=params
      http://en.wikipedia.org/wiki/Wikipedia:Today%27s_featured_picture_%28animation%29/January_20%2C_2007
      http://www.mail-archive.com/rails@lists.rubyonrails.org/
      http://www.amazon.com/Testing-Equal-Sign-In-Path/ref=pd_bbs_sr_1?ie=UTF8&s=books&qid=1198861734&sr=8-1
      http://en.wikipedia.org/wiki/Texas_hold\'em
      https://www.google.com/doku.php?id=gps:resource:scs:start
      http://connect.oraclecorp.com/search?search[q]=green+france&search[type]=Group
      http://of.openfoundry.org/projects/492/download#4th.Release.3
      http://maps.google.co.uk/maps?f=q&q=the+london+eye&ie=UTF8&ll=51.503373,-0.11939&spn=0.007052,0.012767&z=16&iwloc=A
      http://около.кола/колокола
    )

    urls.each do |url|
      auto_link(url).should eq generate_result(url)
    end
  end

  it "keeps links within tags" do
    link_raw = "http://www.rubyonrails.org/images/rails.png"
    link_result = %Q(<img src="#{link_raw}" />)
    auto_link(link_result).should eq link_result
  end

  it "works with brackets" do
    link1_raw = "http://en.wikipedia.org/wiki/Sprite_(computer_graphics)"
    link1_result = generate_result(link1_raw)
    auto_link(link1_raw).should eq link1_result
    auto_link("(link: #{link1_raw})").should eq "(link: #{link1_result})"

    link2_raw = "http://en.wikipedia.org/wiki/Sprite_[computer_graphics]"
    link2_result = generate_result(link2_raw)
    auto_link(link2_raw).should eq link2_result
    auto_link("[link: #{link2_raw}]").should eq "[link: #{link2_result}]"

    link3_raw = "http://en.wikipedia.org/wiki/Sprite_{computer_graphics}"
    link3_result = generate_result(link3_raw)
    auto_link(link3_raw).should eq link3_result
    auto_link("{link: #{link3_raw}}").should eq "{link: #{link3_result}}"
  end

  it "works with multiple brackets" do
    link_raw = "http://en.wikipedia.org/(wiki)/Sprite_(computer_graphics)"
    auto_link("[{((#{link_raw}))}]").should eq "[{((#{generate_result(link_raw)}))}]"
  end

  it "accepts HTML options" do
    text = "Welcome to my new blog at http://www.myblog.com/."
    result = "Welcome to my new blog at <a href=\"http://www.myblog.com/\" class=\"menu\" target=\"_blank\">http://www.myblog.com/</a>."
    auto_link(text, html: {"class" => "menu", "target" => "_blank"}).should eq result
  end

  it "accepts multiple trailing punctuations" do
    url = "http://youtube.com"
    url_result = generate_result(url)
    auto_link(url).should eq url_result
    auto_link("(link: #{url}).").should eq "(link: #{url_result})."
  end

  it "ignores trailing <" do
    url = "https://crystal-lang.org/"
    auto_link("<p>#{url}</p>").should eq "<p>#{generate_result(url)}</p>"
  end

  it "ignores already linked" do
    contents = [
      "<a href=\"https://github.com\">https://github.com</a>",
      "Welcome to my new blog at <a href=\"http://www.myblog.com/\" class=\"menu\" target=\"_blank\">http://www.myblog.com/</a>. Please e-mail me at <a href=\"mailto:me@email.com\" class=\"menu\" target=\"_blank\">me@email.com</a>.",
      "<a href=\"http://www.example.com\">www.example.com</a>",
      "<a href=\"http://www.example.com\" rel=\"nofollow\">www.example.com</a>",
      "<a href=\"http://www.example.com\"><b>www.example.com</b></a>",
      "<a href=\"#close\">close</a> <a href=\"http://www.example.com\"><b>www.example.com</b></a>",
      "<a href=\"#close\">close</a> <a href=\"http://www.example.com\" target=\"_blank\" data-ruby=\"ror\"><b>www.example.com</b></a>",
    ]
    contents.each do |content|
      auto_link(content).should eq content
    end
  end

  it "can autolink url having escaped html" do
    link = %q(<a href="example">http://example.com</a>).gsub("<", "&lt;")
    auto_link(link).should eq %q(&lt;a href="example"><a href="http://example.com">http://example.com</a>&lt;/a>)

    link = HTML.escape(%q(<a href="example">http://example.com</a>))
    auto_link(link).should eq %q(&lt;a href&#61;&quot;example&quot;&gt;<a href="http://example.com">http://example.com</a>&lt;/a&gt;)
  end

  it "plays well with stdlib markdown" do
    content = <<-EOF
auto_link("My blog: http://www.myblog.com")
My blog: <a href="http://www.myblog.com">http://www.myblog.com</a>
EOF
    expected = <<-EOF
<p>auto_link("My blog: <a href="http://www.myblog.com">http://www.myblog.com</a>")
My blog: &lt;a href="http://www.myblog.com">http://www.myblog.com&lt;/a></p>
EOF
    auto_link(Markdown.to_html(content)).should eq expected
  end
end
