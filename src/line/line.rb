require './src/line/messages'
require 'sinatra'
require 'line/bot'
post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    puts event.class
    case event

    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        if event.message['text'] == "あずみん探してー！"
          client.reply_message(event['replyToken'], "検索するから少し待っててー".replyMessage)
        elsif event.message['text'] =~ /あずみん週末行きたい/ or event.message['text'] =~ /あずみん明日行きたい/ or event.message['text'] =~ /あずみん今日行きたい/
          channel_id = get_id(event["source"])
          destroy_memos(channel_id)
          client.reply_message(event['replyToken'], reply_carousel_museums(museum_datas))
        elsif event.message['text'] =~ /あずみん決まってない/
          channel_id = get_id(event["source"])
          destroy_memos(channel_id)
          client.reply_message(event['replyToken'], reply_carousel_museums(museum_datas))
        elsif event.message['text'] =~ /あずみん/ and (event.message['text'] =~ /教えて/ or event.message['text'] =~ /おしえて/ or event.message['text'] =~ /イベント/ or event.message['text'] =~ /いべんと/)
          client.reply_message(event['replyToken'], reply_confirm_start)
        elsif event.message['text'] =~ /あずみん/ and (event.message['text'] =~ /メモ/ or event.message['text'] =~ /めも/) and not event.message['text'] =~ /ったよ！/
          channel = get_id(event["source"])
          client.reply_message(event['replyToken'], reply_carousel_memos(channel))
        elsif event.message['text'] =~ /あずみん/ and (event.message['text'] =~ /他/ or event.message['text'] =~ /ほか/ or event.message['text'] =~ /違う/ or event.message['text'] =~ /ちがう/)
          client.reply_message(event['replyToken'], ["こんなのもあるよー！".replyMessage,reply_carousel_museums(museum_datas)])
        elsif event.message['text'] =~ /あずみん/ and event.message['text'] =~ /かわいい/
          client.reply_message(event['replyToken'], reply_stamp_original)
        elsif event.message['text'] == "あずみん"
          client.reply_message(event['replyToken'], "あずみんイベント！\n → アート系をオススメ！\n\nあずみん遊びたい！\n → アクティビティ系をオススメ！\n\nあずみんほかのはー？\n → 他のイベントを教えるよ！\n\nあずみんメモー！\n → メモしたのが見えるよ！".replyMessage)
        else
          client.reply_message(event['replyToken'], event.message['text'].replyMessage)
        end
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      end

    # Postbackの場合
    when Line::Bot::Event::Postback
      puts 'get postback'
      channel_id = get_id(event["source"])
      data = param_decode(event["postback"]["data"])
      case data["type"]
      when "reply"
        case data["word"]
        when "あずみん行きたい"
          client.reply_message(event['replyToken'], reply_botton_schedule)
        when "呼んだだけ"
          client.reply_message(event['replyToken'], 'もう (おこ)'.replyMessage)
        when "今日だね", "明日だね", "週末だね"
          client.reply_message(event['replyToken'], "おっけー！\nオススメ  検索するから少し待っててー".replyMessage)
        when "決まっていない"
          client.reply_message(event['replyToken'], "おっけー！\nオススメ  検索するから少し待っててー".replyMessage)
        end
      when "keep"
        Keep.create(:channel=>channel_id, :json=>event["postback"]["data"])
        client.reply_message(event['replyToken'], "#{data['title']} をメモったよ！".replyMessage))
      when "destroy"
        puts "#{channel_id} -> #{event['postback']['data']}"
        destroy_memo(channel_id,event['postback']['data'])
      when "gps"
        case data["source_page"]
        when 'museum'
          client.reply_message(event['replyToken'], reply_gps(data['title'],data['address'],data['latitude'],data['longitude']))
        end
      end
    end
  }
  "OK"
end
