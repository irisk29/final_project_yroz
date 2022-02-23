class StoreDTO {
  String name;
  String phoneNumber;
  String address;
  List<String> categories;
  Map<int, DateTime> operationHours;
  String? image;

  StoreDTO(this.name, this.phoneNumber, this.address, this.categories,
      this.operationHours, this.image);
}
