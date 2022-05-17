class Secret {
  final String KEY;
  final String IV;
  final String API_KEY;
  final String COMPANY_EMAIL;
  final String S3_URL;
  final String CASH_BACK_PRECENTEGE;

  Secret(
      {this.KEY = "",
      this.IV = "",
      this.API_KEY = "",
      this.COMPANY_EMAIL = "",
      this.S3_URL = "",
      this.CASH_BACK_PRECENTEGE = ""});
  factory Secret.fromJson(Map<String, dynamic> jsonMap) {
    return new Secret(
        KEY: jsonMap["KEY"],
        IV: jsonMap["IV"],
        API_KEY: jsonMap["API_KEY"],
        COMPANY_EMAIL: jsonMap["COMPANY_EMAIL"],
        S3_URL: jsonMap["S3_URL"],
        CASH_BACK_PRECENTEGE: jsonMap["CASH_BACK_PRECENTEGE"]);
  }
}
