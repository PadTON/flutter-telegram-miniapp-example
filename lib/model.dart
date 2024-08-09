class RemoteMobileNode {
  RemoteMobileNode({
    required this.device,
    required this.provider,
    required this.account,
    required this.name,
    required this.appName,
    required this.imageUrl,
    required this.aboutUrl,
    required this.platforms,
    required this.bridgeUrl,
    required this.universalLink,
    required this.openMethod,
  });

  final Device? device;
  final String? provider;
  final Account? account;
  final String? name;
  final String? appName;
  final String? imageUrl;
  final String? aboutUrl;
  final List<String> platforms;
  final String? bridgeUrl;
  final String? universalLink;
  final String? openMethod;

  factory RemoteMobileNode.fromJson(Map<String, dynamic> json) {
    return RemoteMobileNode(
      device: json["device"] == null ? null : Device.fromJson(json["device"]),
      provider: json["provider"],
      account: json["account"] == null ? null : Account.fromJson(json["account"]),
      name: json["name"],
      appName: json["appName"],
      imageUrl: json["imageUrl"],
      aboutUrl: json["aboutUrl"],
      platforms: json["platforms"] == null ? [] : List<String>.from(json["platforms"]!.map((x) => x)),
      bridgeUrl: json["bridgeUrl"],
      universalLink: json["universalLink"],
      openMethod: json["openMethod"],
    );
  }
}

class Account {
  Account({
    required this.address,
    required this.chain,
    required this.walletStateInit,
    required this.publicKey,
  });

  final String? address;
  final String? chain;
  final String? walletStateInit;
  final String? publicKey;

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      address: json["address"],
      chain: json["chain"],
      walletStateInit: json["walletStateInit"],
      publicKey: json["publicKey"],
    );
  }
}

class Device {
  Device({
    required this.platform,
    required this.appName,
    required this.appVersion,
    required this.maxProtocolVersion,
    required this.features,
  });

  final String? platform;
  final String? appName;
  final String? appVersion;
  final int? maxProtocolVersion;
  final List<dynamic> features;

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      platform: json["platform"],
      appName: json["appName"],
      appVersion: json["appVersion"],
      maxProtocolVersion: json["maxProtocolVersion"],
      features: json["features"] == null ? [] : List<dynamic>.from(json["features"]!.map((x) => x)),
    );
  }
}

class FeatureClass {
  FeatureClass({
    required this.name,
    required this.maxMessages,
  });

  final String? name;
  final int? maxMessages;

  factory FeatureClass.fromJson(Map<String, dynamic> json) {
    return FeatureClass(
      name: json["name"],
      maxMessages: json["maxMessages"],
    );
  }
}
