class Event {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String venue;
  final String location;
  final String? logoUrl;
  final String organizerId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.venue,
    required this.location,
    this.logoUrl,
    required this.organizerId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    try {
      return Event(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        startDate: DateTime.parse(json['startDate']?.toString() ?? json['start_date']?.toString() ?? DateTime.now().toIso8601String()),
        endDate: DateTime.parse(json['endDate']?.toString() ?? json['end_date']?.toString() ?? DateTime.now().toIso8601String()),
        venue: json['venue']?.toString() ?? '',
        location: json['location']?.toString() ?? json['venue']?.toString() ?? '',
        logoUrl: json['logoUrl']?.toString() ?? json['logo_url']?.toString(),
        organizerId: json['organizerId']?.toString() ?? json['organizer_id']?.toString() ?? 'default',
        isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt']?.toString() ?? json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(json['updatedAt']?.toString() ?? json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      print('Event.fromJson error: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'venue': venue,
      'location': location,
      'logo_url': logoUrl,
      'organizer_id': organizerId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate.millisecondsSinceEpoch,
      'venue': venue,
      'location': location,
      'logo_url': logoUrl,
      'organizer_id': organizerId,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int),
      venue: map['venue'] as String? ?? '',
      location: map['location'] as String? ?? map['venue'] as String? ?? '',
      logoUrl: map['logo_url'] as String?,
      organizerId: map['organizer_id'] as String,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Event copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? venue,
    String? location,
    String? logoUrl,
    String? organizerId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      venue: venue ?? this.venue,
      location: location ?? this.location,
      logoUrl: logoUrl ?? this.logoUrl,
      organizerId: organizerId ?? this.organizerId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Event(id: $id, name: $name, venue: $venue, startDate: $startDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}