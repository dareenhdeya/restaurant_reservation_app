import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';

class BookTableScreen extends StatefulWidget {
  final String restaurantId;
  final int tableNumber;
  final String customerId;

  const BookTableScreen({
    super.key,
    required this.restaurantId,
    required this.tableNumber,
    required this.customerId,
  });

  @override
  State<BookTableScreen> createState() => _BookTableScreenState();
}

class _BookTableScreenState extends State<BookTableScreen> {
  int seats = 1;
  DateTime selectedDate = DateTime.now();
  String? selectedTime;

  final List<String> timeSlots = [
    '10:00 AM',
    '12:00 PM',
    '02:00 PM',
    '04:00 PM',
    '06:00 PM',
  ];

  String get formattedDate =>
      '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}';

  @override
  void initState() {
    super.initState();

    // أول ما الشاشة تفتح
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().listenToReservationsForRestaurant(
        widget.restaurantId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Book Table')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Table ${widget.tableNumber}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // 👥 Seats
            const Text('Number of Seats'),
            DropdownButton<int>(
              value: seats,
              items: List.generate(
                6,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text('${i + 1} Seats'),
                ),
              ),
              onChanged: (value) {
                setState(() => seats = value!);
              },
            ),

            const SizedBox(height: 20),

            // 📅 Date
            const Text('Reservation Date'),
            TextButton(
              child: Text(formattedDate),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );

                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                    selectedTime = null;
                  });

                  // 🔄 نحدّث الحجوزات حسب اليوم الجديد
                  context
                      .read<BookingProvider>()
                      .listenToReservationsForRestaurant(widget.restaurantId);
                }
              },
            ),

            const SizedBox(height: 20),

            // ⏰ Time Slots
            const Text(
              'Available Time Slots',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: bookingProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                      itemCount: timeSlots.length,
                      itemBuilder: (context, index) {
                        final time = timeSlots[index];

                        final isBooked = bookingProvider.isTimeBooked(
                          tableNumber: widget.tableNumber,
                        );

                        return GestureDetector(
                          onTap: isBooked
                              ? null
                              : () {
                                  setState(() {
                                    selectedTime = time;
                                  });
                                },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isBooked
                                  ? Colors.grey
                                  : selectedTime == time
                                  ? Colors.blue
                                  : Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                time,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // ✅ Confirm
            ElevatedButton(
              onPressed: selectedTime == null
                  ? null
                  : () async {
                      await bookingProvider.bookTable(
                        restaurantId: widget.restaurantId,
                        tableNumber: widget.tableNumber,
                        seats: seats,
                        date: formattedDate,
                        customerId:widget.customerId,
                        timeSlot: selectedTime!,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Booking confirmed')),
                      );

                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
              child: const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
