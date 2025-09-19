class BadgeTemplate {
  final String id;
  final String name;
  final String? eventId;
  final String labelSizeId;
  final bool isVipTemplate;
  final String backgroundColor;
  final String? backgroundImage;
  final Map<String, dynamic>? backgroundSettings;
  final String textColor;
  final String? logoUrl;
  final List<BadgeField> fields;
  final BadgeDimensions dimensions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  BadgeTemplate({
    required this.id,
    required this.name,
    this.eventId,
    required this.labelSizeId,
    required this.isVipTemplate,
    required this.backgroundColor,
    this.backgroundImage,
    this.backgroundSettings,
    required this.textColor,
    this.logoUrl,
    required this.fields,
    required this.dimensions,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory BadgeTemplate.fromJson(Map<String, dynamic> json) {
    return BadgeTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      eventId: json['eventId'] as String?,
      labelSizeId: json['labelSizeId'] as String,
      isVipTemplate: json['isVipTemplate'] as bool? ?? false,
      backgroundColor: json['backgroundColor'] as String? ?? '#ffffff',
      backgroundImage: json['backgroundImage'] as String?,
      backgroundSettings: json['backgroundSettings'] as Map<String, dynamic>?,
      textColor: json['textColor'] as String? ?? '#000000',
      logoUrl: json['logoUrl'] as String?,
      fields: (json['fields'] as List<dynamic>? ?? [])
          .map((field) => BadgeField.fromJson(field as Map<String, dynamic>))
          .toList(),
      dimensions: BadgeDimensions.fromJson(json['dimensions'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'eventId': eventId,
      'labelSizeId': labelSizeId,
      'isVipTemplate': isVipTemplate,
      'backgroundColor': backgroundColor,
      'backgroundImage': backgroundImage,
      'backgroundSettings': backgroundSettings,
      'textColor': textColor,
      'logoUrl': logoUrl,
      'fields': fields.map((field) => field.toJson()).toList(),
      'dimensions': dimensions.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}

class BadgeField {
  final String id;
  final String type; // 'text', 'qr', 'logo', 'image'
  final String? content;
  final BadgePosition position;
  final BadgeSize size;
  final BadgeStyle style;

  BadgeField({
    required this.id,
    required this.type,
    this.content,
    required this.position,
    required this.size,
    required this.style,
  });

  factory BadgeField.fromJson(Map<String, dynamic> json) {
    return BadgeField(
      id: json['id'] as String,
      type: json['type'] as String,
      content: json['content'] as String?,
      position: BadgePosition.fromJson(json['position'] as Map<String, dynamic>),
      size: BadgeSize.fromJson(json['size'] as Map<String, dynamic>),
      style: BadgeStyle.fromJson(json['style'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'position': position.toJson(),
      'size': size.toJson(),
      'style': style.toJson(),
    };
  }
}

class BadgePosition {
  final double x;
  final double y;

  BadgePosition({required this.x, required this.y});

  factory BadgePosition.fromJson(Map<String, dynamic> json) {
    return BadgePosition(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }
}

class BadgeSize {
  final double width;
  final double height;

  BadgeSize({required this.width, required this.height});

  factory BadgeSize.fromJson(Map<String, dynamic> json) {
    return BadgeSize(
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
    };
  }
}

class BadgeStyle {
  final double? fontSize;
  final String? fontWeight;
  final String? color;

  BadgeStyle({this.fontSize, this.fontWeight, this.color});

  factory BadgeStyle.fromJson(Map<String, dynamic> json) {
    return BadgeStyle(
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      fontWeight: json['fontWeight'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'fontWeight': fontWeight,
      'color': color,
    };
  }
}

class BadgeDimensions {
  final double width;
  final double height;

  BadgeDimensions({required this.width, required this.height});

  factory BadgeDimensions.fromJson(Map<String, dynamic> json) {
    return BadgeDimensions(
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
    };
  }

  // Convert dimensions to 2.4x3.5 inch format for thermal printing
  // Standard badge size: 3.5" x 2.4" (88.9mm x 60.96mm)
  double get widthInMM => width * 0.264583; // Convert pixels to mm (assuming 96 DPI)
  double get heightInMM => height * 0.264583;
  
  bool get isStandardBadgeSize {
    const targetWidthMM = 88.9; // 3.5 inches
    const targetHeightMM = 60.96; // 2.4 inches
    const tolerance = 5.0; // 5mm tolerance
    
    return (widthInMM - targetWidthMM).abs() <= tolerance &&
           (heightInMM - targetHeightMM).abs() <= tolerance;
  }
}