import 'dart:typed_data';

import 'package:cbor/simple.dart';

class CanonicalBlock {
  late int blockType;
  late int blockNumber;
  late Uint8List data;

  CanonicalBlock(this.blockType, this.blockNumber, this.data);

  CanonicalBlock.fromObj(List<Object?> obj) {
    if (obj.length != 5) {
      throw 'Expected 5 elements in canonical block, unsupported block encoding';
    }
    blockType = obj[0] as int;
    blockNumber = obj[1] as int;
    data = Uint8List.fromList(obj[4] as List<int>);
  }

  /// Returns [value] plus 1.
  List<Object> toObj() {
    return [blockType, blockNumber, 0, 0, data];
  }
}
