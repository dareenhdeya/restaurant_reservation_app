import 'package:customer_app/services/booking_service.dart';
import 'package:flutter/material.dart';

class BookTableScreen extends StatefulWidget {
  final String restaurantId;
  final int tableNumber;

  BookTableScreen({required this.restaurantId, required this.tableNumber});

  @override
  State<BookTableScreen> createState() => _BookTableScreenState();
}

class _BookTableScreenState extends State<BookTableScreen> {
  int seats = 1;
  DateTime selectedDate = DateTime.now();
  String? selectedTime;

  final bookingService = BookingService();

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Table')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Table ${widget.tableNumber}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // 👥 Seats
            Text('Number of Seats'),
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
            Text('Reservation Date'),
            TextButton(
              child: Text(formattedDate),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 30)),
                );

                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                    selectedTime = null;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            // ⏰ Time Slots
            Text(
              'Available Time Slots',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder(
                stream: bookingService.getReservations(
                  restaurantId: widget.restaurantId,
                  date: formattedDate,
                ),
                builder: (context, snapshot) {
                  final reservations = snapshot.hasData
                      ? snapshot.data!.docs
                      : [];

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: timeSlots.length,
                    itemBuilder: (context, index) {
                      final time = timeSlots[index];

                      final isBooked = reservations.any(
                        (r) =>
                            r['tableNumber'] == widget.tableNumber &&
                            r['timeSlot'] == time,
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
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // ✅ Confirm
            ElevatedButton(
              onPressed: selectedTime == null ? null : _confirmBooking,
              child: Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBooking() async {
    await bookingService.bookTable(
      restaurantId: widget.restaurantId,
      tableNumber: widget.tableNumber,
      seats: seats,
      date: formattedDate,
      timeSlot: selectedTime!,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Booking confirmed')));

    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
