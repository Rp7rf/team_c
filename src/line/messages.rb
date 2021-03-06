require 'net/http'
require 'uri'
require 'json'
require "rexml/document"
require './src/line/library'
require './src/line/museum'
# "デバッグ用"
def reply_message(message='')
  message = {
    type: 'text',
    text: message
  }
end

# "あずみんイベント教えてー"
def reply_confirm_start
  {
    "type": "template",
    "altText": "イベント選択中",
    "template": {
      "type": "confirm",
      "text": "おっけー！\nイベント行きたいの？",
      "actions": [
        Action.new('postback', {
          :type => "postback",
          :label => "行きたい！",
          :text => "行きたい！",
          :data => {:type => 'reply', :word=> 'あずみん行きたい'}
        }).postback,
        Action.new('postback', {
          :type => "postback",
          :label => "呼んだだけ",
          :text => "呼んだだけ",
          :data => {:type => 'reply', :word=> '呼んだだけ'}
        }).postback
      ]
    }
  }
end

# "行きたい！" 日程選択
def reply_botton_schedule
  {
    "type": "template",
    "altText": "日程調整中",
    "template": {
      "type": "buttons",
      "thumbnailImageUrl": "https://res.cloudinary.com/dn8dt0pep/image/upload/v1484641224/question.jpg",
      "title": "日程決めるよ",
      "text": "いつがいい？",
      "actions": [
        Action.new('postback', {
          :type => "postback",
          :label => "今日",
          :text => "あずみん今日行きたい",
          :data => {:type => 'reply', :word=> '今日だね'}
        }).postback,
        Action.new('postback', {
          :type => "postback",
          :label => "明日",
          :text => "あずみん明日行きたい",
          :data => {:type => 'reply', :word=> '明日だね'}
        }).postback,
        Action.new('postback', {
          :type => "postback",
          :label => "週末",
          :text => "あずみん週末行きたい",
          :data => {:type => 'reply', :word=> '週末だね'}
        }).postback,
        Action.new('postback', {
          :type => "postback",
          :label => "決まってない",
          :text => "あずみん決まってない",
          :data => {:type => 'reply', :word=> '決まっていない'}
        }).postback
      ]
    }
  }
end

# メモのカルーセルを返す
def reply_carousel_memos(channel='')
  keeps = Keep.where(channel: channel).
    order("updated_at desc").limit(5).map {|event|
    	data =  param_decode(event['json'])
    	if data['source_page'] == 'museum'
	      make_carousel_museum_cloumns(data,1)
  		end
  }
  if keeps.count == 0
  	reply_message("メモ帳に何もないよー！")
  else
    {
      "type": "template",
      "altText": "メモ帳閲覧中",
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

def reply_stamp_original
  stickers = [180,184,186,199,208,206,236,243]
  {
    type: 'sticker',
    packageId: "3",
    stickerId: stickers[rand(stickers.count-1)].to_s
  }
end