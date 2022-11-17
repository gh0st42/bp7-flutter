import 'dart:typed_data';

import 'package:bp7/CanonicalBlock.dart';
import 'package:bp7/PrimaryBlock.dart';
import 'package:cbor/simple.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bp7/bp7.dart';

void main() {
  test('test simple cbor test', () {
    final cb = Uint8List.fromList(cbor.encode([
      1,
      2,
      [
        3,
        4,
        [5, 6]
      ]
    ]));
    print(convertToHexString(cb));
  });
  test('test manual bundle creation', () {
    final pb =
        PrimaryBlock("dtn://n1/", "dtn://n2/inbox", "dtn://n1/", 3600, 2342, 0);
    //final pb_cbor = pb.toObj();
    //print(convertToHexString(Uint8List.fromList(pb_cbor)));
    //cborPrettyPrint(pb_cbor);
    final payload = CanonicalBlock(1, 1, Uint8List.fromList([1, 2, 3]));
    final bp7 = BP7(pb, payload);
    final cbor = bp7.toCbor();
    print(cbor);
    print(convertToHexString(cbor));
    //expect(calculator.addOne(2), 3);
    //expect(calculator.addOne(-7), -6);
    //expect(calculator.addOne(0), 1);
  });

  test('test simple bundle creation', () {
    final bndl = BP7.fromValues(
        "dtn://src/bla", "dtn://dst/blub", 3600, Uint8List.fromList([1, 2, 3]));
    final cbor = bndl.toCbor();
    print(convertToHexString(cbor));
  });

  test('test simple bundle decoding', () {
    final bndl = BP7.fromHexString(
        "9f8807000082016a2f2f6e322f696e626f788201652f2f6e312f8201652f2f6e312f821b000000a56d68291400190e10850101000043010203ff");
    print(bndl.payload);
    print(bndl.destination);
    print(dtntimeToString(bndl.creationTimestamp));
  });
}
