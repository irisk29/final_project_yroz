class Secret {
  final String KEY;
  final String IV;
  final String API_KEY;

  Secret({this.KEY = "", this.IV = "", this.API_KEY = ""});
  factory Secret.fromJson(Map<String, dynamic> jsonMap) {
    return new Secret(KEY: jsonMap["KEY"], IV: jsonMap["IV"], API_KEY: jsonMap["API_KEY"]);
  }
}