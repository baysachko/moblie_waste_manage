class YourDataModel {
  final String id;
  final dynamic value;

  YourDataModel({required this.id, required this.value});

  factory YourDataModel.fromMap(Map<String, dynamic> map) {
    return YourDataModel(
      id: map['id'],
      value: map['value'],
    );
  }

  @override
  String toString() {
    return 'YourDataModel{id: $id, value: $value}';
  }
}
