exports.models =
  event:
    id: "event"
    properties:
      eventId:
        type: "long"
      host:
        type: "string"
      source:
        type: "string"
      location:
        type: "string"
      description:
        type: "string"
      name:
        type: "string"
      date:
        type: "string"
      type:
        type: "string"
      url:
        type: "string"
  eventRangeRequestHeader:
    id: "eventRangeRequestHeader"
    properties:
      from:
        type: "long"
      to:
        type: "long"
      max:
        type: "long"
      offset:
        type: "long"



  # Pet:
  #   id: "Pet"
  #   properties:
  #     tags:
  #       items:
  #         $ref: "Tag"

  #       type: "Array"

  #     id:
  #       type: "long"

  #     category:
  #       type: "Category"

  #     status:
  #       allowableValues:
  #         valueType: "LIST"
  #         values: ["available", "pending", "sold"]
  #         valueType: "LIST"

  #       description: "pet status in the store"
  #       type: "string"

  #     name:
  #       type: "string"

  #     photoUrls:
  #       items:
  #         type: "string"

  #       type: "Array"

  # Tag:
  #   id: "Tag"
  #   properties:
  #     id:
  #       type: "long"

  #     name:
  #       type: "string"