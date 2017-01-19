require 'net/http'
require 'uri'
require 'json'
require "rexml/document" 
require './library'

# "デバッグ用"
def reply_message(message='')
  message = {
    type: 'text',
    text: message
  }
end

# "あずみん起きて"
def reply_confirm_start
  {
    "type": "template",
    "altText": "this is a confirm template",
    "template": {
      "type": "confirm",
      "text": "おはよう\nイベント行きたいの？",
      "actions": [
        {
          "type": "postback",
          "label": "行きたい！",
          "text": "行きたい！",
          "data": "行きたい"
        },
        {
          "type": "postback",
          "label": "呼んだだけ",
          "text": "呼んだだけ",
          "data": "呼んだだけ"
        }
      ]
    }
  }
end

# "行きたい！" 日程選択
def reply_botton_schedule
  {
    "type": "template",
    "altText": "this is a buttons template",
    "template": {
      "type": "buttons",
      "thumbnailImageUrl": "https://res.cloudinary.com/dn8dt0pep/image/upload/v1484641224/question.jpg",
      "title": "日程決めるよ",
      "text": "いつがいい？",
      "actions": [
        {
          "type": "postback",
          "label": "今日",
          "text": "今日行きたい",
          "data": "今日だね"
        },
        {
          "type": "postback",
          "label": "明日",
          "text": "明日行きたい",
          "data": "明日だね"
        },
        {
          "type": "postback",
          "label": "週末",
          "text": "週末行きたい",
          "data": "週末だね"
        },
        {
          "type": "postback",
          "label": "決まってない",
          "text": "決まってない",
          "data": "決まっていない"
        }
      ]
	  }
	}
end

def reply_carousel_museums(museums)
  randoms = (0...museums.count).to_a.shuffle![0...5]
  randoms.map!{|item| make_carousel_cloumns(museums[item])}
  {
    "type": "template",
    "altText": "this is a carousel template",
    "template": {
       "type": "carousel",
       "columns": randoms
    }
  }
end

def reply_carousel_bookmarks(channel='')
  keeps = Keep.where(channel: channel).
    order("updated_at desc").limit(5).map {|event|
      make_carousel_cloumns(param_decode(event['json']))
  }
  if keeps.count == 0
  	reply_message("まだブックマークされてないよー！")
  else
    {
      "type": "template",
      "altText": "this is a carousel template",
      "template": {
        "type": "carousel",
        "columns": keeps
      }
    }
  end 
end

def make_carousel_cloumns(museum)
  keep = museum.dup
  keep["type"] = 'keep'
  gps = museum.dup
  gps["type"] = 'gps'
  {
    "thumbnailImageUrl": "https://res.cloudinary.com/dn8dt0pep/image/upload/v1484641224/question.jpg",
    "title": museum["title"].slice(0,40-museum["area"].size-1) + '/' + museum["area"],
    "text": museum["body"],
    "actions": [
      {
        "type": "uri",
        "label": "詳しく見る",
        "uri": museum["url"]
      },
      {
        "type": "postback",
        "label": "場所を見る",
        "data": param_encode(gps)
      },
      {
        "type": "postback",
        "label": "ブックマークする",
        "text": museum["title"] + ' をブックマークしました',
        "data": param_encode(keep)
      }
    ]
  }
end

def reply_museum_datas(url = rand_genre[:url])
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

def reply_gps(title='',address='',latitude='',longitude='')
  {
    "type": "location",
    "title": title,
    "address": address,
    "latitude": latitude,
    "longitude": longitude
	}
end