import 'package:flutter/material.dart';

import 'StoreDTO.dart';

class PhysicalStoreDTO extends StoreDTO {
  String qrCode;

  PhysicalStoreDTO(
      String id,
      String name,
      String address,
      String phoneNumber,
      List<String> categories,
      Map<String, List<TimeOfDay>> operationHours,
      String? image,
      String qrCode)
      : this.qrCode = qrCode,
        super(id, name, phoneNumber, address, categories, operationHours,
            image) {}
}
