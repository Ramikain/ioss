class BluetoothPrinter {
  final String name;
  final String address;
  final bool isConnected;
  final int? rssi;
  final String? type;

  BluetoothPrinter({
    required this.name,
    required this.address,
    this.isConnected = false,
    this.rssi,
    this.type,
  });

  BluetoothPrinter copyWith({
    String? name,
    String? address,
    bool? isConnected,
    int? rssi,
    String? type,
  }) {
    return BluetoothPrinter(
      name: name ?? this.name,
      address: address ?? this.address,
      isConnected: isConnected ?? this.isConnected,
      rssi: rssi ?? this.rssi,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'isConnected': isConnected,
      'rssi': rssi,
      'type': type,
    };
  }

  factory BluetoothPrinter.fromJson(Map<String, dynamic> json) {
    return BluetoothPrinter(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      isConnected: json['isConnected'] ?? false,
      rssi: json['rssi'],
      type: json['type'],
    );
  }

  @override
  String toString() {
    return 'BluetoothPrinter(name: $name, address: $address, isConnected: $isConnected)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BluetoothPrinter &&
        other.name == name &&
        other.address == address;
  }

  @override
  int get hashCode {
    return name.hashCode ^ address.hashCode;
  }
}