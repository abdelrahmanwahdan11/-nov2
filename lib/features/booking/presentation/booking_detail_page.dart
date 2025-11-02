import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/models/booking.dart';
import '../../../core/models/field.dart';
import '../../../core/models/time_slot.dart';
import '../../../core/services/providers.dart';
import 'create_booking_controller.dart';

class BookingDetailPage extends ConsumerStatefulWidget {
  const BookingDetailPage({super.key, required this.fieldId});

  final String fieldId;

  @override
  ConsumerState<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends ConsumerState<BookingDetailPage> {
  TimeSlot? _selectedSlot;
  bool _splitPayment = false;

  @override
  Widget build(BuildContext context) {
    final fieldAsync = ref.watch(fieldDetailProvider(widget.fieldId));
    final bookingsAsync = ref.watch(fieldBookingsProvider(widget.fieldId));
    final bookingState = ref.watch(createBookingControllerProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الحجز')),
      body: fieldAsync.when(
        data: (field) {
          if (field == null) {
            return const Center(child: Text('لا يوجد ملعب')); 
          }
          return bookingsAsync.when(
            data: (bookings) {
              return userAsync.when(
                data: (user) {
                  if (user == null) {
                    return const Center(child: Text('الرجاء اختيار مستخدم')); 
                  }
                  final booking = bookingState.value;
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _imageCarousel(field),
                      const SizedBox(height: 24),
                      _availabilityGrid(field, bookings),
                      const SizedBox(height: 24),
                      _pricingCard(context, field, user.id),
                      if (bookingState.isLoading)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (booking != null) ...[
                        const SizedBox(height: 16),
                        _qrSection(booking, user.id),
                      ],
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('خطأ: $error')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('خطأ: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('خطأ: $error')),
      ),
    );
  }

  Widget _imageCarousel(Field field) {
    final photos = field.availabilitySlots.length.clamp(1, 3);
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: photos,
        itemBuilder: (_, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.grey.shade300,
              child: Center(child: Text('صورة ${index + 1}')),
            ),
          ),
        ),
      ),
    );
  }

  Widget _availabilityGrid(Field field, List<Booking> bookings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('التوافر', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: field.availabilitySlots.map<Widget>((slot) {
                final isTaken = bookings.any((booking) {
                  final booked = TimeSlot(start: booking.start, end: booking.end);
                  return booked.overlaps(slot);
                });
                final selected = _selectedSlot == slot;
                return FilterChip(
                  label: Text('${slot.start.hour.toString().padLeft(2, '0')}:${slot.start.minute.toString().padLeft(2, '0')}'),
                  selected: selected,
                  onSelected: isTaken
                      ? null
                      : (value) {
                          setState(() {
                            _selectedSlot = value ? slot : null;
                          });
                        },
                  selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  disabledColor: Colors.grey.shade300,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pricingCard(BuildContext context, Field field, String userId) {
    final durationHours = _selectedSlot == null
        ? 1
        : _selectedSlot!.duration.inMinutes / 60;
    final cost = field.pricePerHour * durationHours;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('السعر وسياسة الإلغاء', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('${cost.toStringAsFixed(0)} ر.س'),
            const SizedBox(height: 8),
            const Text('سياسة الإلغاء: قبل 6 ساعات'),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _splitPayment,
              onChanged: (value) => setState(() => _splitPayment = value),
              title: const Text('تقسيم الدفع'),
              subtitle: const Text('قسمة متساوية محليًا'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _selectedSlot == null
                  ? null
                  : () async {
                      await ref.read(createBookingControllerProvider.notifier).create(
                            fieldId: field.id,
                            participantIds: [userId],
                            slot: _selectedSlot!,
                            price: cost,
                            splitPayment: _splitPayment,
                          );
                    },
              icon: const Icon(Icons.payment),
              label: const Text('تأكيد الحجز'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qrSection(Booking booking, String userId) {
    final data = 'booking:${booking.id}:$userId:${DateTime.now().toIso8601String()}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('تأكيد الحضور'),
            const SizedBox(height: 12),
            QrImageView(data: data, size: 180),
            const SizedBox(height: 8),
            const Text('يمكن مسح الرمز خلال 15 دقيقة من موعد الحجز.'),
          ],
        ),
      ),
    );
  }
}
