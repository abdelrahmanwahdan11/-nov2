import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/models/models.dart';
import '../../core/state/app_scope.dart';

class BookingDetailPage extends StatefulWidget {
  const BookingDetailPage({super.key, this.fieldId});

  final String? fieldId;

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final field = state.fields.firstWhere(
      (f) => f.id == (widget.fieldId ?? state.fields.first.id),
      orElse: () => state.fields.first,
    );
    final slots = field.availabilitySlots;

    return Scaffold(
      appBar: AppBar(title: Text('حجز ${field.sport}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.venueId, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('السعة ${field.capacity} لاعب · ${field.pricePerHour.toStringAsFixed(0)} ر.س/ساعة'),
            const SizedBox(height: 16),
            Text('المواعيد المتاحة', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(slots.length, (index) {
                final slot = slots[index];
                final selected = _selectedIndex == index;
                final label = '${slot.start.hour.toString().padLeft(2, '0')}:00';
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedIndex = index),
                ).animate().fadeIn(duration: 200.ms, delay: (index * 60).ms);
              }),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedIndex == null
                    ? null
                    : () {
                        final slot = slots[_selectedIndex!];
                        final booking = Booking(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          fieldId: field.id,
                          userIds: [state.currentUser?.id ?? 'u_001'],
                          start: slot.start,
                          end: slot.end,
                          price: field.pricePerHour,
                          status: 'pending',
                          splitPayment: true,
                        );
                        state.addBooking(booking);
                        Navigator.pop(context);
                      },
                child: const Text('احجز الآن'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
