require 'net/http'
require 'uri'
require 'json'
require "rexml/document" 
require './library'
require './asoview'
require './museum'
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

def reply_carousel_memos(channel='')
  keeps = Keep.where(channel: channel).
    order("updated_at desc").limit(5).map {|event|
    	data =  param_decode(event['json'])
      # make_carousel_XX_cloumns(data, template_type)
    	if data['source_page'] == 'museum'
	      make_carousel_museum_cloumns(data,1)
  		else
  			make_carousel_asoview_cloumns(data,1)
  		end
  }
  if keeps.count == 0
  	reply_message("メモ帳に何もないよー！")
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

def reply_gps(title='',address='',latitude='',longitude='')
  {
    "type": "location",
    "title": title,
    "address": address,
    "latitude": latitude,
    "longitude": longitude
  }
end