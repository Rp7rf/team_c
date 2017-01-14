#def event_template(title, location, fee, body, image, num)
def art_template
  {
    "type": "template",
    "altText": "this is a carousel template",
    "template": {
      "type": "carousel",
      "columns": [
#        art.colum
        {
          "thumbnailImageUrl": art[4],
          "title": art[0],
          "text": art[1],
          "actions": [
              {
                  "type": "postback",
                  "label": "Buy",
                  "data": "action=buy&itemid=111"
              },
              {
                  "type": "postback",
                  "label": "Add to cart",
                  "data": "action=add&itemid=111"
              },
              {
                  "type": "uri",
                  "label": "View detail",
                  "uri": "http://example.com/page/111"
              }
          ]
        }
       ]
    }
  }
end

class Art
  attr_accessor :title , :location, :fee, :body, :image

  def set(title:, location:, fee:, body:, image:)
    self.title = title
    self.location = location
    self.fee = fee
    self.image = image
  end

  def colum
    {
      "thumbnailImageUrl": self.image,
      "title": self.title,
      "text": self.location,
      "actions": [
          {
              "type": "postback",
              "label": "Buy",
              "data": "action=buy&itemid=111"
          },
          {
              "type": "postback",
              "label": "Add to cart",
              "data": "action=add&itemid=111"
          },
          {
              "type": "uri",
              "label": "View detail",
              "uri": "http://example.com/page/111"
          }
      ]
    }
  end
end
