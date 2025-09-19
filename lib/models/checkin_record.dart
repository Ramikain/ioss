class CheckinRecord {
  final String id;
  final String attendeeId;
  final String eventId;
  final String checkedInBy;
  final DateTime checkedInAt;
  final String? notes;
  final bool isPrinted;
  final DateTime? printedAt;

  CheckinRecord({
    required this.id,
    required this.attendeeId,
    required this.eventId,
    required this.checkedInBy,
    required this.checkedInAt,
    this.notes,
    required this.isPrinted,
    this.printedAt,
  });

  factory CheckinRecord.fromJson(Map<String, dynamic> json) {
    return CheckinRecord(
      id: json['id'] as String,
      attendeeId: json['attendee_id'] as String,
      eventId: json['event_id'] as String,
      checkedInBy: json['checked_in_by'] as String,
      checkedInAt: DateTime.parse(json['checked_in_at'] as String),
      notes: json['notes'] as String?,
      isPrinted: json['is_printed'] as bool? ?? false,
      printedAt: json['printed_at'] != null
          ? DateTime.parse(json['printed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attendee_id': attendeeId,
      'event_id': eventId,
      'checked_in_by': checkedInBy,
      'checked_in_at': checkedInAt.toIso8601String(),
      'notes': notes,
      'is_printed': isPrinted,
      'printed_at': printedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'attendee_id': attendeeId,
      'event_id': eventId,
      'checked_in_by': checkedInBy,
      'checked_in_at': checkedInAt.millisecondsSinceEpoch,
      'notes': notes,
      'is_printed': isPrinted ? 1 : 0,
      'printed_at': printedAt?.millisecondsSinceEpoch,
    };
  }

  factory CheckinRecord.fromMap(Map<String, dynamic> map) {
    return CheckinRecord(
      id: map['id'] as String,
      attendeeId: map['attendee_id'] as String,
      eventId: map['event_id'] as String,
      checkedInBy: map['checked_in_by'] as String,
      checkedInAt: DateTime.fromMillisecondsSinceEpoch(map['checked_in_at'] as int),
      notes: map['notes'] as String?,
      isPrinted: (map['is_printed'] as int) == 1,
      printedAt: map['printed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['printed_at'] as int)
          : null,
    );
  }

  CheckinRecord copyWith({
    String? id,
    String? attendeeId,
    String? eventId,
    String? checkedInBy,
    DateTime? checkedInAt,
    String? notes,
    bool? isPrinted,
    DateTime? printedAt,
  }) {
    return CheckinRecord(
      id: id ?? this.id,
      attendeeId: attendeeId ?? this.attendeeId,
      eventId: eventId ?? this.eventId,
      checkedInBy: checkedInBy ?? this.checkedInBy,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      notes: notes ?? this.notes,
      isPrinted: isPrinted ?? this.isPrinted,
      printedAt: printedAt ?? this.printedAt,
    );
  }

  @override
  String toString() {
    return 'CheckinRecord(id: $id, attendeeId: $attendeeId, checkedInAt: $checkedInAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CheckinRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}