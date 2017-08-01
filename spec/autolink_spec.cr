require "./spec_helper"

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
      generate_result(url).should eq auto_link(url)
    end
  end

  it "keeps links within tags" do
    link_raw = "http://www.rubyonrails.org/images/rails.png"
    link_result = %Q(<img src="#{link_raw}" />)
    link_result.should eq auto_link(link_result)
  end

  it "works with brackets" do
    link1_raw = "http://en.wikipedia.org/wiki/Sprite_(computer_graphics)"
    link1_result = generate_result(link1_raw)
    link1_result.should eq auto_link(link1_raw)
    "(link: #{link1_result})".should eq auto_link("(link: #{link1_raw})")

    link2_raw = "http://en.wikipedia.org/wiki/Sprite_[computer_graphics]"
    link2_result = generate_result(link2_raw)
    link2_result.should eq auto_link(link2_raw)
    "[link: #{link2_result}]".should eq auto_link("[link: #{link2_raw}]")

    link3_raw = "http://en.wikipedia.org/wiki/Sprite_{computer_graphics}"
    link3_result = generate_result(link3_raw)
    link3_result.should eq auto_link(link3_raw)
    "{link: #{link3_result}}".should eq auto_link("{link: #{link3_raw}}")
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

  pending "accepts multiple trailing punctuations" do
    url = "http://youtube.com"
    url_result = generate_result(url)
    url_result.should eq auto_link(url)
    "(link: #{url_result}).".should eq auto_link("(link: #{url}).")
  end
end
