class Secret {
  final String KEY;
  final String IV;

  Secret({this.KEY = "", this.IV = ""});
  factory Secret.fromJson(Map<String, dynamic> jsonMap) {
    return new Secret(KEY: jsonMap["KEY"], IV: jsonMap["IV"]);
  }
}