enum AttendeeStatus {
  registered,
  checkedIn,
  checkedOut,
  cancelled,
}

enum AttendeeType {
  regular,
  vip,
  speaker,
  staff,
  sponsor,
}

class Attendee {
  final String id;
  final String eventId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? company;
  final String? jobTitle;
  final AttendeeType type;
  final AttendeeStatus status;
  final String qrCode;
  final DateTime? checkedInAt;
  final String? checkedInBy;
  final Map<String, dynamic>? customFields;
  final DateTime registeredAt;
  final DateTime updatedAt;
  final DateTime? createdAt;

  Attendee({
    required this.id,
    required this.eventId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.company,
    this.jobTitle,
    required this.type,
    required this.status,
    required this.qrCode,
    this.checkedInAt,
    this.checkedInBy,
    this.customFields,
    required this.registeredAt,
    required this.updatedAt,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName';
  
  bool get isVip => type == AttendeeType.vip;
  bool get isCheckedIn => status == AttendeeStatus.checkedIn;
  bool get canCheckIn => status == AttendeeStatus.registered;

  factory Attendee.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase and snake_case field names from API
    return Attendee(
      id: json['id'] as String,
      eventId: (json['eventId'] ?? json['event_id']) as String,
      firstName: (json['firstName'] ?? json['first_name']) as String,
      lastName: (json['lastName'] ?? json['last_name']) as String,
      email: json['email'] as String,
      phone: (json['phone'] ?? json['phone_number']) as String?,
      company: json['company'] as String?,
      jobTitle: (json['jobTitle'] ?? json['job_title']) as String?,
      type: _parseAttendeeType(json),
      status: _parseAttendeeStatus(json),
      qrCode: (json['qrCode'] ?? json['qr_code']) as String,
      checkedInAt: _parseDateTime(json['checkedInAt'] ?? json['checked_in_at']),
      checkedInBy: (json['checkedInBy'] ?? json['checked_in_by']) as String?,
      customFields: (json['customFields'] ?? json['custom_fields']) as Map<String, dynamic>?,
      registeredAt: _parseDateTime(json['registeredAt'] ?? json['registered_at'] ?? json['createdAt'] ?? json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']) ?? DateTime.now(),
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
    );
  }

  static AttendeeType _parseAttendeeType(Map<String, dynamic> json) {
    final typeStr = json['type'] ?? json['attendee_type'] ?? json['ticketType'] ?? 'regular';
    if (json['isVip'] == true || json['is_vip'] == true) {
      return AttendeeType.vip;
    }
    return AttendeeType.values.firstWhere(
      (e) => e.name.toLowerCase() == typeStr.toString().toLowerCase(),
      orElse: () => AttendeeType.regular,
    );
  }

  static AttendeeStatus _parseAttendeeStatus(Map<String, dynamic> json) {
    if (json['isCheckedIn'] == true || json['is_checked_in'] == true) {
      return AttendeeStatus.checkedIn;
    }
    final statusStr = json['status'] ?? 'registered';
    return AttendeeStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == statusStr.toString().toLowerCase(),
      orElse: () => AttendeeStatus.registered,
    );
  }

  static DateTime? _parseDateTime(dynamic dateStr) {
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr.toString());
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'company': company,
      'job_title': jobTitle,
      'type': type.name,
      'status': status.name,
      'qr_code': qrCode,
      'checked_in_at': checkedInAt?.toIso8601String(),
      'checked_in_by': checkedInBy,
      'custom_fields': customFields,
      'registered_at': registeredAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'company': company,
      'job_title': jobTitle,
      'type': type.name,
      'status': status.name,
      'qr_code': qrCode,
      'checked_in_at': checkedInAt?.millisecondsSinceEpoch,
      'checked_in_by': checkedInBy,
      'custom_fields': customFields != null ? customFields.toString() : null,
      'registered_at': registeredAt.millisecondsSinceEpoch,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Attendee.fromMap(Map<String, dynamic> map) {
    return Attendee(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      company: map['company'] as String?,
      jobTitle: map['job_title'] as String?,
      type: AttendeeType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AttendeeType.regular,
      ),
      status: AttendeeStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AttendeeStatus.registered,
      ),
      qrCode: map['qr_code'] as String,
      checkedInAt: map['checked_in_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['checked_in_at'] as int)
          : null,
      checkedInBy: map['checked_in_by'] as String?,
      customFields: map['custom_fields'] != null
          ? Map<String, dynamic>.from(map['custom_fields'] as Map)
          : null,
      registeredAt: DateTime.fromMillisecondsSinceEpoch(map['registered_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
    );
  }

  Attendee copyWith({
    String? id,
    String? eventId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? company,
    String? jobTitle,
    AttendeeType? type,
    AttendeeStatus? status,
    String? qrCode,
    DateTime? checkedInAt,
    String? checkedInBy,
    Map<String, dynamic>? customFields,
    DateTime? registeredAt,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return Attendee(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      jobTitle: jobTitle ?? this.jobTitle,
      type: type ?? this.type,
      status: status ?? this.status,
      qrCode: qrCode ?? this.qrCode,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      checkedInBy: checkedInBy ?? this.checkedInBy,
      customFields: customFields ?? this.customFields,
      registeredAt: registeredAt ?? this.registeredAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Attendee(id: $id, name: $fullName, email: $email, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attendee && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}