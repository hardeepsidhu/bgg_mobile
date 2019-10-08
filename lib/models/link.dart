class Link {
  String id;
  String type;
  String value;

  Link({this.id, this.type, this.value});

  Link.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    value = json['value'];
  }
}
