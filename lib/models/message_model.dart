class MessageModel {
  MessageModel({
    required this.senderID,
    required this.receiverID,
    required this.messageType,
    required this.readTime,
    required this.sendTime,
    required this.messageContent,
  });
  late String senderID;
  late String receiverID;
  late String messageType;
  late String readTime;
  late String sendTime;
  late String messageContent;

  MessageModel.fromJson(Map<String, dynamic> json){
    senderID = json['senderID'];
    receiverID = json['receiverID'];
    messageType = json['messageType'];
    readTime = json['readTime'];
    sendTime = json['sendTime'];
    messageContent = json['messageContent'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['senderID'] = senderID;
    _data['receiverID'] = receiverID;
    _data['messageType'] = messageType;
    _data['readTime'] = readTime;
    _data['sendTime'] = sendTime;
    _data['messageContent'] = messageContent;
    return _data;
  }
}