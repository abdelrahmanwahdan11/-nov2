import 'package:hive/hive.dart';

import '../../models/booking.dart';
import '../../models/enums.dart';
import '../../models/event.dart';
import '../../models/field.dart';
import '../../models/geo_point.dart';
import '../../models/health_metric.dart';
import '../../models/notification_item.dart';
import '../../models/story.dart';
import '../../models/time_slot.dart';
import '../../models/user.dart';
import '../../models/venue.dart';
import '../../models/wallet_tx.dart';

class GeoPointAdapter extends TypeAdapter<GeoPoint> {
  @override
  final int typeId = 9;

  @override
  GeoPoint read(BinaryReader reader) {
    final lat = reader.readDouble();
    final lon = reader.readDouble();
    return GeoPoint(lat: lat, lon: lon);
  }

  @override
  void write(BinaryWriter writer, GeoPoint obj) {
    writer
      ..writeDouble(obj.lat)
      ..writeDouble(obj.lon);
  }
}

class TimeSlotAdapter extends TypeAdapter<TimeSlot> {
  @override
  final int typeId = 10;

  @override
  TimeSlot read(BinaryReader reader) {
    final start = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final end = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    return TimeSlot(start: start, end: end);
  }

  @override
  void write(BinaryWriter writer, TimeSlot obj) {
    writer
      ..writeInt(obj.start.millisecondsSinceEpoch)
      ..writeInt(obj.end.millisecondsSinceEpoch);
  }
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final hasGender = reader.readBool();
    final gender = hasGender ? reader.readString() : null;
    final hasAge = reader.readBool();
    final age = hasAge ? reader.readInt() : null;
    final hasHeight = reader.readBool();
    final height = hasHeight ? reader.readDouble() : null;
    final hasWeight = reader.readBool();
    final weight = hasWeight ? reader.readDouble() : null;
    final level = Level.values[reader.readByte()];
    final preferences = (reader.read() as List).cast<String>();
    final hasAvatar = reader.readBool();
    final avatar = hasAvatar ? reader.readString() : null;
    return User(
      id: id,
      name: name,
      gender: gender,
      age: age,
      heightCm: height,
      weightKg: weight,
      level: level,
      preferences: preferences,
      avatarUrl: avatar,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeBool(obj.gender != null);
    if (obj.gender != null) {
      writer.writeString(obj.gender!);
    }
    writer..writeBool(obj.age != null);
    if (obj.age != null) {
      writer.writeInt(obj.age!);
    }
    writer..writeBool(obj.heightCm != null);
    if (obj.heightCm != null) {
      writer.writeDouble(obj.heightCm!);
    }
    writer..writeBool(obj.weightKg != null);
    if (obj.weightKg != null) {
      writer.writeDouble(obj.weightKg!);
    }
    writer
      ..writeByte(obj.level.index)
      ..write(obj.preferences)
      ..writeBool(obj.avatarUrl != null);
    if (obj.avatarUrl != null) {
      writer.writeString(obj.avatarUrl!);
    }
  }
}

class VenueAdapter extends TypeAdapter<Venue> {
  @override
  final int typeId = 1;

  @override
  Venue read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final geo = reader.read() as GeoPoint;
    final address = reader.readString();
    final amenities = (reader.read() as List).cast<String>();
    final photos = (reader.read() as List).cast<String>();
    final rating = reader.readDouble();
    final hasPolicies = reader.readBool();
    final policies = hasPolicies ? reader.readString() : null;
    return Venue(
      id: id,
      name: name,
      geo: geo,
      address: address,
      amenities: amenities,
      photos: photos,
      rating: rating,
      policies: policies,
    );
  }

  @override
  void write(BinaryWriter writer, Venue obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..write(obj.geo)
      ..writeString(obj.address)
      ..write(obj.amenities)
      ..write(obj.photos)
      ..writeDouble(obj.rating)
      ..writeBool(obj.policies != null);
    if (obj.policies != null) {
      writer.writeString(obj.policies!);
    }
  }
}

class FieldAdapter extends TypeAdapter<Field> {
  @override
  final int typeId = 2;

  @override
  Field read(BinaryReader reader) {
    final id = reader.readString();
    final venueId = reader.readString();
    final sport = Sport.values[reader.readByte()];
    final capacity = reader.readInt();
    final pricePerHour = reader.readDouble();
    final slots = (reader.read() as List).cast<TimeSlot>();
    return Field(
      id: id,
      venueId: venueId,
      sport: sport,
      capacity: capacity,
      pricePerHour: pricePerHour,
      availabilitySlots: slots,
    );
  }

  @override
  void write(BinaryWriter writer, Field obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.venueId)
      ..writeByte(obj.sport.index)
      ..writeInt(obj.capacity)
      ..writeDouble(obj.pricePerHour)
      ..write(obj.availabilitySlots);
  }
}

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 3;

  @override
  Event read(BinaryReader reader) {
    final id = reader.readString();
    final type = EventType.values[reader.readByte()];
    final title = reader.readString();
    final description = reader.readString();
    final level = Level.values[reader.readByte()];
    final requirements = (reader.read() as List).cast<String>();
    final timeWindow = TimeWindow.values[reader.readByte()];
    final startAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final endAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final hasRoute = reader.readBool();
    final route = hasRoute ? (reader.read() as List).cast<GeoPoint>() : null;
    final location = reader.read() as GeoPoint;
    final capacity = reader.readInt();
    final fee = reader.readDouble();
    final organizerId = reader.readString();
    final attendees = (reader.read() as List).cast<String>();
    return Event(
      id: id,
      type: type,
      title: title,
      description: description,
      level: level,
      requirements: requirements,
      timeWindow: timeWindow,
      startAt: startAt,
      endAt: endAt,
      route: route,
      location: location,
      capacity: capacity,
      fee: fee,
      organizerId: organizerId,
      attendeeIds: attendees,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeString(obj.id)
      ..writeByte(obj.type.index)
      ..writeString(obj.title)
      ..writeString(obj.description)
      ..writeByte(obj.level.index)
      ..write(obj.requirements)
      ..writeByte(obj.timeWindow.index)
      ..writeInt(obj.startAt.millisecondsSinceEpoch)
      ..writeInt(obj.endAt.millisecondsSinceEpoch)
      ..writeBool(obj.route != null);
    if (obj.route != null) {
      writer.write(obj.route!);
    }
    writer
      ..write(obj.location)
      ..writeInt(obj.capacity)
      ..writeDouble(obj.fee)
      ..writeString(obj.organizerId)
      ..write(obj.attendeeIds);
  }
}

class BookingAdapter extends TypeAdapter<Booking> {
  @override
  final int typeId = 4;

  @override
  Booking read(BinaryReader reader) {
    final id = reader.readString();
    final fieldId = reader.readString();
    final userIds = (reader.read() as List).cast<String>();
    final start = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final end = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final price = reader.readDouble();
    final status = BookingStatus.values[reader.readByte()];
    final splitPayment = reader.readBool();
    final hasPayments = reader.readBool();
    final payments = hasPayments
        ? Map<String, bool>.from(reader.read() as Map)
        : const <String, bool>{};
    return Booking(
      id: id,
      fieldId: fieldId,
      userIds: userIds,
      start: start,
      end: end,
      price: price,
      status: status,
      splitPayment: splitPayment,
      payments: payments,
    );
  }

  @override
  void write(BinaryWriter writer, Booking obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.fieldId)
      ..write(obj.userIds)
      ..writeInt(obj.start.millisecondsSinceEpoch)
      ..writeInt(obj.end.millisecondsSinceEpoch)
      ..writeDouble(obj.price)
      ..writeByte(obj.status.index)
      ..writeBool(obj.splitPayment)
      ..writeBool(obj.payments.isNotEmpty);
    if (obj.payments.isNotEmpty) {
      writer.write(obj.payments);
    }
  }
}

class HealthMetricAdapter extends TypeAdapter<HealthMetric> {
  @override
  final int typeId = 5;

  @override
  HealthMetric read(BinaryReader reader) {
    final id = reader.readString();
    final userId = reader.readString();
    final date = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final hasWeight = reader.readBool();
    final weight = hasWeight ? reader.readDouble() : null;
    final hasWaist = reader.readBool();
    final waist = hasWaist ? reader.readDouble() : null;
    final hasBodyFat = reader.readBool();
    final bodyFat = hasBodyFat ? reader.readDouble() : null;
    final hasSteps = reader.readBool();
    final steps = hasSteps ? reader.readInt() : null;
    final hasCalories = reader.readBool();
    final calories = hasCalories ? reader.readInt() : null;
    final hasWater = reader.readBool();
    final water = hasWater ? reader.readInt() : null;
    final isMonthly = reader.readBool();
    return HealthMetric(
      id: id,
      userId: userId,
      date: date,
      weightKg: weight,
      waistCm: waist,
      bodyFatPct: bodyFat,
      steps: steps,
      calories: calories,
      waterMl: water,
      isMonthly: isMonthly,
    );
  }

  @override
  void write(BinaryWriter writer, HealthMetric obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.userId)
      ..writeInt(obj.date.millisecondsSinceEpoch)
      ..writeBool(obj.weightKg != null);
    if (obj.weightKg != null) {
      writer.writeDouble(obj.weightKg!);
    }
    writer..writeBool(obj.waistCm != null);
    if (obj.waistCm != null) {
      writer.writeDouble(obj.waistCm!);
    }
    writer..writeBool(obj.bodyFatPct != null);
    if (obj.bodyFatPct != null) {
      writer.writeDouble(obj.bodyFatPct!);
    }
    writer..writeBool(obj.steps != null);
    if (obj.steps != null) {
      writer.writeInt(obj.steps!);
    }
    writer..writeBool(obj.calories != null);
    if (obj.calories != null) {
      writer.writeInt(obj.calories!);
    }
    writer..writeBool(obj.waterMl != null);
    if (obj.waterMl != null) {
      writer.writeInt(obj.waterMl!);
    }
    writer.writeBool(obj.isMonthly);
  }
}

class StoryAdapter extends TypeAdapter<Story> {
  @override
  final int typeId = 6;

  @override
  Story read(BinaryReader reader) {
    final id = reader.readString();
    final userId = reader.readString();
    final isPro = reader.readBool();
    final mediaUrl = reader.readString();
    final caption = reader.readString();
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final likes = reader.readInt();
    final reactions = (reader.read() as List).cast<String>();
    final hidden = reader.readBool();
    return Story(
      id: id,
      userId: userId,
      isPro: isPro,
      mediaUrl: mediaUrl,
      caption: caption,
      createdAt: createdAt,
      likes: likes,
      reactions: reactions,
      hidden: hidden,
    );
  }

  @override
  void write(BinaryWriter writer, Story obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.userId)
      ..writeBool(obj.isPro)
      ..writeString(obj.mediaUrl)
      ..writeString(obj.caption)
      ..writeInt(obj.createdAt.millisecondsSinceEpoch)
      ..writeInt(obj.likes)
      ..write(obj.reactions)
      ..writeBool(obj.hidden);
  }
}

class WalletTxAdapter extends TypeAdapter<WalletTx> {
  @override
  final int typeId = 7;

  @override
  WalletTx read(BinaryReader reader) {
    final id = reader.readString();
    final userId = reader.readString();
    final amount = reader.readDouble();
    final type = WalletType.values[reader.readByte()];
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final hasNote = reader.readBool();
    final note = hasNote ? reader.readString() : null;
    return WalletTx(
      id: id,
      userId: userId,
      amount: amount,
      type: type,
      createdAt: createdAt,
      note: note,
    );
  }

  @override
  void write(BinaryWriter writer, WalletTx obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.userId)
      ..writeDouble(obj.amount)
      ..writeByte(obj.type.index)
      ..writeInt(obj.createdAt.millisecondsSinceEpoch)
      ..writeBool(obj.note != null);
    if (obj.note != null) {
      writer.writeString(obj.note!);
    }
  }
}

class NotificationItemAdapter extends TypeAdapter<NotificationItem> {
  @override
  final int typeId = 8;

  @override
  NotificationItem read(BinaryReader reader) {
    final id = reader.readString();
    final userId = reader.readString();
    final title = reader.readString();
    final body = reader.readString();
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final read = reader.readBool();
    final type = reader.readString();
    return NotificationItem(
      id: id,
      userId: userId,
      title: title,
      body: body,
      createdAt: createdAt,
      read: read,
      type: type,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationItem obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.userId)
      ..writeString(obj.title)
      ..writeString(obj.body)
      ..writeInt(obj.createdAt.millisecondsSinceEpoch)
      ..writeBool(obj.read)
      ..writeString(obj.type);
  }
}

void registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(0)) {
    Hive
      ..registerAdapter(UserAdapter())
      ..registerAdapter(VenueAdapter())
      ..registerAdapter(FieldAdapter())
      ..registerAdapter(EventAdapter())
      ..registerAdapter(BookingAdapter())
      ..registerAdapter(HealthMetricAdapter())
      ..registerAdapter(StoryAdapter())
      ..registerAdapter(WalletTxAdapter())
      ..registerAdapter(NotificationItemAdapter())
      ..registerAdapter(GeoPointAdapter())
      ..registerAdapter(TimeSlotAdapter());
  }
}
