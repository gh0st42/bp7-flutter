library bp7;

import 'dart:typed_data';

import 'package:bp7/CanonicalBlock.dart';
import 'package:bp7/PrimaryBlock.dart';
import 'package:cbor/simple.dart';

String convertToHexString(Uint8List buf) {
  var list = <String>[];
  for (var i = 0; i < buf.length; i++) {
    list.add(buf[i].toRadixString(16).padLeft(2, '0'));
  }
  return list.join();
}

Uint8List hexToUint8List(String hex) {
  if (hex.length % 2 != 0) {
    throw 'Odd number of hex digits';
  }
  var l = hex.length ~/ 2;
  var result = Uint8List(l);
  for (var i = 0; i < l; ++i) {
    var x = int.parse(hex.substring(i * 2, (2 * (i + 1))), radix: 16);
    if (x.isNaN) {
      throw 'Expected hex string';
    }
    result[i] = x;
  }
  return result;
}

int dtntimeToUnix(int dtntime) {
  return dtntime + DTNTIME_BASE_MS;
}

String dtntimeToString(int dtntime) {
  return DateTime.fromMillisecondsSinceEpoch(dtntimeToUnix(dtntime),
          isUtc: false)
      .toString();
}

const DTNTIME_BASE_MS = 946684800000;

/// A Bundle.
class BP7 {
  late PrimaryBlock primaryBlock;
  late CanonicalBlock payloadBlock;

  BP7(this.primaryBlock, this.payloadBlock);

  BP7.fromValues(
      String srcEID, String dstEID, int lifetime, Uint8List payload) {
    var now = DateTime.now().millisecondsSinceEpoch;
    now = now -
        DTNTIME_BASE_MS; // convert unix timestamp to dtn time, starting from y2k
    primaryBlock =
        PrimaryBlock("dtn://n1/", "dtn://n2/inbox", "dtn://n1/", 3600, now, 0);
    payloadBlock = CanonicalBlock(1, 1, payload);
  }
  BP7.fromHexString(String hexstring) {
    final cborBuf = hexToUint8List(hexstring);
    fromCbor(cborBuf);
  }

  BP7.fromCbor(Uint8List cborBuf) {
    fromCbor(cborBuf);
  }

  void fromCbor(Uint8List cborBuf) {
    Object? bundle = cbor.decode(cborBuf);
    if (bundle is! List) {
      throw 'Expected CBOR list';
    }
    List<Object?> blocks = bundle;
    if (blocks.length < 2) {
      throw 'Expected at least 2 blocks';
    }
    primaryBlock = PrimaryBlock.fromObj(blocks[0] as List<Object?>);
    payloadBlock = CanonicalBlock.fromObj(blocks[1] as List<Object?>);
  }

  String get source => primaryBlock.source;
  String get destination => primaryBlock.destination;
  String get reportto => primaryBlock.reportto;
  int get lifetime => primaryBlock.lifetime;
  int get creationTimestamp => primaryBlock.creationTimestamp;
  int get sequenceNumber => primaryBlock.seqno;
  Uint8List get payload => payloadBlock.data;

  Uint8List toCbor() {
    var bundle =
        cbor.encode([this.primaryBlock.toObj(), this.payloadBlock.toObj()]);
    bundle[0] = 0x9f;
    bundle.add(0xff);
    return Uint8List.fromList(bundle);
  }
}
