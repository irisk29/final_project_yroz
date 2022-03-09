import 'package:flutter/material.dart';

import 'StoreDTO.dart';

class PhysicalStoreDTO extends StoreDTO {
  String qrCode;

  PhysicalStoreDTO(
  {required String id,
      required String name,
      required String address,
      required String phoneNumber,
      required List<String> categories,
      required Map<String, List<TimeOfDay>> operationHours,
      String? image,
      required String qrCode})
      : this.qrCode = qrCode,
        super(id, name, phoneNumber, address, categories, operationHours,
            image) {}
}
