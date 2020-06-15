module ChatHelper 
  def generate_posts(txt)
    txt_pref = "{\"events\":
        [{\"type\":\"message\",\"replyToken\":\"xxxx\",
          \"source\":{\"userId\":\"xxxx\",\"type\":\"user\"},
          \"timestamp\":1591852909179,\"mode\":\"active\",
          \"message\":{\"type\":\"text\",\"id\":\"xxxx\",\"text\":"
    txt_suff = "}}],\"destination\":\"xxxx\"}"
    txt_pref + txt + txt_suff
  end
end