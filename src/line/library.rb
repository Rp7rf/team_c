def param_encode(data)
  string = ""
  f = false
  for key in data.keys
    string += '&' if f == true
    string += key + '=' + data[key]
    f = true
  end
  string
end

def param_decode(string)
  hash = {}
  string.split('&').map{|item| 
    hash[item.split('=')[0]] = item.split('=')[1]
  }
  hash
end

def get_id(event)
  case event["type"]
  when "user"
    return event["userId"]
  when "group"
    return event["groupId"]
  when "room"
    return event["roomId"]
  else
    return "error"
  end
end

def destroy_memos(channel_id)
  Keep.where({channel: channel_id}).delete_all
end

def destroy_memo(channel_id,json=nil)
  json = param_decode(json)
  json['type'] = 'keep'
  Keep.where({channel: channel_id, json: param_encode(json)}).delete_all
end