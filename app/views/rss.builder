xml.instruct! :xml, :version => '1.0'
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Tira La Bomba"
    xml.description "Todo lo que no podías decir.Hasta ahora."
    xml.link "http://tiralabomba.com"

    @posts.each do |post|
      xml.item do
        xml.link "http://tiralabomba.com/show/#{post.id}"
        xml.description post.content
        xml.pubDate Time.parse(post.created_at.to_s).rfc822()
        xml.guid "http://tiralabomba.com/show/#{post.id}"
      end
    end
  end
end