require 'open-uri'
require 'nokogiri'

# 美術館のジャンルを自動的に返す
def rand_museum_genre
  genres = [
    {:name => "2D/イラスト", :url => "http://www.tokyoartbeat.com/list/event_type_print_illustration.ja.xml"},
    {:name => "2D/デッサン", :url => "http://www.tokyoartbeat.com/list/event_type_print_drawing.ja.xml"},
    {:name => "2D/グラフィックス", :url => "http://www.tokyoartbeat.com/list/event_type_print_graphicdesign.ja.xml"},
    {:name => "2D/写真", :url => "http://www.tokyoartbeat.com/list/event_type_print_photo.ja.xml"},
    {:name => "2D/版画", :url => "http://www.tokyoartbeat.com/list/event_type_print_prints.ja.xml"},
    {:name => "2D/珍しい", :url => "http://www.tokyoartbeat.com/list/event_type_print_other.ja.xml"},

    {:name => "3D/建築", :url => "http://www.tokyoartbeat.com/list/event_type_3D_architecture.ja.xml"},
    {:name => "3D/彫刻&立体", :url => "http://www.tokyoartbeat.com/list/event_type_3D_sculpture.ja.xml"},
    {:name => "3D/工芸", :url => "http://www.tokyoartbeat.com/list/event_type_3D_crafts.ja.xml"},
    {:name => "3D/ファッション", :url => "http://www.tokyoartbeat.com/list/event_type_3D_fashion.ja.xml"},
    {:name => "3D/家具", :url => "http://www.tokyoartbeat.com/list/event_type_3D_furniture.ja.xml"},
    {:name => "3D/インスタレーション", :url => "http://www.tokyoartbeat.com/list/event_type_3D_installation.ja.xml"},
    {:name => "3D/プロダクト", :url => "http://www.tokyoartbeat.com/list/event_type_3D_productdesign.ja.xml"},
    {:name => "3D/陶芸", :url => "http://www.tokyoartbeat.com/list/event_type_3D_ceramics.ja.xml"},
    {:name => "3D/珍しい", :url => "http://www.tokyoartbeat.com/list/event_type_3D_other.ja.xml"},

    {:name => "スクリーン/映画", :url => "http://www.tokyoartbeat.com/list/event_type_screen_film.ja.xml"},
    {:name => "スクリーン/デジタル", :url => "http://www.tokyoartbeat.com/list/event_type_screen_digital.ja.xml"},

    {:name => "パーティー", :url => "http://www.tokyoartbeat.com/list/event_type_misc_party.ja.xml"},
    {:name => "トークイベント", :url => "http://www.tokyoartbeat.com/list/event_type_misc_talk.ja.xml"},
    {:name => "パフォーマンスアート", :url => "http://www.tokyoartbeat.com/list/event_type_misc_performance.ja.xml"},
    {:name => "一般公募", :url => "http://www.tokyoartbeat.com/list/event_type_misc_performance.ja.xml"},
  ]
  genres[rand(genres.count-1).to_i]
end

# APIから展覧会の情報を取ってくる
def museum_datas(url = rand_museum_genre[:url])
  uri = URI.parse(url)
  begin
    response = Net::HTTP.start(uri.host) do |http|
    http.get(uri.request_uri)
  end
  puts 'get response'
  case response
  when Net::HTTPSuccess
    doc = REXML::Document.new(response.body)
    array = []
    doc.elements.each('Events/Event') do |event|
      res = {}
      res["title"]     = event.elements['Name'].text
      res["url"]       = event.attribute('href').to_s
      res["area"]      = event.elements['Venue/Area'].text
      res["body"]      = event.elements['Description'].text.gsub(/\n/, '').slice(0,59)
      res["address"]   = event.elements['Venue/Address'].text
      res["latitude"]  = event.elements['Latitude'].text
      res["longitude"] = event.elements['Longitude'].text
      array.push(res)
    end
    return array
  when Net::HTTPRedirection
    puts "Redirection: code=#{response.code} message=#{response.message}"
  else
    puts "HTTP ERROR: code=#{response.code} message=#{response.message}"
  end
  rescue IOError => e
    puts e.message
  rescue JSON::ParserError => e
    puts e.message
  rescue => e
    puts e.message
  end
end

# カルーセルを返す
def reply_carousel_museums(museums)
  # museum からランダムに5つ以下を選択
  randoms = (0...museums.count).to_a.shuffle![0...5]
  columns = randoms.map{|item|
    # テンプレートの作成
    make_carousel_museum_cloumns(museums[item])
  }
  {
    "type": "template",
    "altText": "this is a carousel template",
    "template": {
       "type": "carousel",
       "columns": columns
    }
  }
end

# カルーセルの一つの
def make_carousel_museum_cloumns(museum,template_type=0)
  museum["source_page"] = 'museum'

  actions = []
  # 詳細ボタンと, 住所ボタンの追加
  actions.push(make_action_url(museum["url"]))
  museum["type"] = 'gps'
  actions.push(make_action_address(param_encode(museum)))

  if template_type == 0
    # メモボタンの追加
    museum["type"] = 'keep'
    actions.push(make_action_memo(museum))
  else
    # 削除ボタンの追加
    museum["type"] = 'destroy'
    actions.push(make_action_destroy(museum))
  end
  {
    "thumbnailImageUrl": "https://res.cloudinary.com/dn8dt0pep/image/upload/v1484641224/question.jpg",
    "title": museum["title"].slice(0,40-museum["area"].size-1) + '/' + museum["area"],
    "text": museum["body"],
    "actions": actions
  }
end