class TodoModel {
  int? category;
  String? dueDate;
  String? note;
  int? priority;
  String? tags;
  String? title;
  String? uid;
  String? id;
  List<dynamic>? urlList;

  TodoModel(
      {this.category,
      this.dueDate,
      this.note,
      this.priority,
      this.uid,
      this.tags,
      this.id,
      this.urlList,
      this.title});

  TodoModel.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    dueDate = json['due_date'];
    note = json['note'];
    priority = json['priority'];
    tags = json['tags'];
    title = json['title'];
    uid = json['uid'];
    id = json['id'];
    urlList = json['urlList'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category'] = category;
    data['due_date'] = dueDate;
    data['note'] = note;
    data['priority'] = priority;
    data['tags'] = tags;
    data['title'] = title;
    data['uid'] = uid;
    data['id'] = id;
    data['urlList'] = urlList;
    return data;
  }
}
