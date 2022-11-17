import 'dart:typed_data';

import 'package:bp7/bp7.dart';
import 'package:cbor/simple.dart';

class PrimaryBlock {
  late String source;
  late String destination;
  late String reportto;
  late int lifetime;
  late int creationTimestamp;
  late int seqno;

  PrimaryBlock(this.source, this.destination, this.reportto, this.lifetime,
      this.creationTimestamp, this.seqno);

  PrimaryBlock.fromObj(List<Object?> obj) {
    if (obj.length != 8) {
      throw 'Expected 8 elements in primary block, unsupported block encoding';
    }
    // 3 = destination
    //blockType = obj[0] as int;
    //blockNumber = obj[1] as int;
    //data = Uint8List.fromList(obj[4] as List<int>);
    destination = eidDecode(obj[3] as List<Object?>);
    source = eidDecode(obj[4] as List<Object?>);
    reportto = eidDecode(obj[5] as List<Object?>);
    loadCTS(obj[6] as List<Object?>);
    lifetime = obj[7] as int;
  }
  String eidDecode(List<Object?> obj) {
    var eid = "dtn:";
    if (obj.length != 2) {
      throw 'Expected 2 elements in EID, invalid endpoint ID encoding';
    }
    if (obj[0] as int != 1) {
      throw 'Expected "dtn" as EID scheme';
    }
    eid += obj[1] as String;
    return eid;
  }

  void loadCTS(List<Object?> obj) {
    if (obj.length != 2) {
      throw 'Expected 2 elements in creation timestamp';
    }
    creationTimestamp = obj[0] as int;
    seqno = obj[1] as int;
  }

  List<Object> eidEncode(String input) {
    final parts = input.split(":");
    if (parts[0] != "dtn") {
      throw Exception("Invalid EID prefix");
    }
    //final encodedEid = cbor.encode([1, parts[1]]);
    //print(encodedEid);
    //return Uint8List.fromList(encodedEid);
    return [1, parts[1]];
  }

  /// Returns [value] plus 1.
  List<Object> toObj() {
    return [
      7,
      0,
      0,
      eidEncode(destination),
      eidEncode(source),
      eidEncode(reportto),
      [creationTimestamp, seqno],
      lifetime
    ];
  }
}
