import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../events_controller.dart';

class EventsView extends GetView<EventsController> {
  const EventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Events'),
          backgroundColor: AppTheme.primaryYellow,
          foregroundColor: AppTheme.darkText,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddEventDialog(context),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Events'),
              Tab(text: 'My Events'),
              Tab(text: 'My Tickets'),
            ],
            indicatorColor: AppTheme.darkText,
            labelColor: AppTheme.darkText,
            unselectedLabelColor: AppTheme.lightText,
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.lightYellow,
                AppTheme.white,
              ],
            ),
          ),
          child: TabBarView(
            children: [
              _buildAllEventsTab(),
              _buildMyEventsTab(),
              _buildMyTicketsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllEventsTab() {
    return Obx(() => controller.isLoading.value
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
            itemCount: controller.events.length,
            itemBuilder: (context, index) {
              final event = controller.events[index];
              return _buildEventCard(event, true);
            },
          ));
  }

  Widget _buildMyEventsTab() {
    return Obx(() => ListView.builder(
          padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
          itemCount: controller.userEvents.length,
          itemBuilder: (context, index) {
            final event = controller.userEvents[index];
            return _buildEventCard(event, false);
          },
        ));
  }

  Widget _buildMyTicketsTab() {
    return Obx(() => ListView.builder(
          padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
          itemCount: controller.userTickets.length,
          itemBuilder: (context, index) {
            final ticket = controller.userTickets[index];
            return _buildTicketCard(ticket);
          },
        ));
  }

  Widget _buildEventCard(Map<String, dynamic> event, bool showPurchaseButton) {
    // Safely parse the date
    DateTime? eventDateTime;
    if (event['date_time'] != null) {
      try {
        eventDateTime = DateTime.parse(event['date_time']).toLocal();
      } catch (e) {
        // Handle potential parsing errors
        print('Error parsing date: ${event['date_time']}');
      }
    }

    return Card(
      margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          if (event['images']?.isNotEmpty == true)
            Container(
              height: ScreenUtil().setHeight(200),
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: CachedNetworkImage(
                  imageUrl: event['images'][0],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppTheme.lightYellow,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.lightYellow,
                    child: const Icon(Icons.event, size: 80),
                  ),
                ),
              ),
            ),
          
          Padding(
            padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Name
                Text(
                  event['name'] ?? 'Event',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(18),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                
                SizedBox(height: ScreenUtil().setHeight(5)),
                
                // Date and Time
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: ScreenUtil().setSp(16), color: AppTheme.lightText),
                    SizedBox(width: ScreenUtil().setWidth(5)),
                    Text(
                      eventDateTime != null
                          ? DateFormat.yMMMd().add_jm().format(eventDateTime)
                          : 'Date not available',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(14),
                        color: AppTheme.lightText,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: ScreenUtil().setHeight(5)),
                
                // Location
                Row(
                  children: [
                    Icon(Icons.location_on, size: ScreenUtil().setSp(16), color: AppTheme.lightText),
                    SizedBox(width: ScreenUtil().setWidth(5)),
                    Expanded(
                      child: Text(
                        event['location'] ?? 'Location not available',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(14),
                          color: AppTheme.lightText,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: ScreenUtil().setHeight(10)),
                
                // Description
                Text(
                  event['description'] ?? 'No description available',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(14),
                    color: AppTheme.lightText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: ScreenUtil().setHeight(10)),
                
                // Ticket Info
                Row(
                  children: [
                    Icon(Icons.attach_money, size: ScreenUtil().setSp(16), color: AppTheme.primaryYellow),
                    SizedBox(width: ScreenUtil().setWidth(5)),
                    Text(
                      '\$${(event['ticket_price'] ?? 0.0).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(16),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryYellow,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${event['available_tickets'] ?? 0} tickets left',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(14),
                        color: AppTheme.lightText,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: ScreenUtil().setHeight(15)),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showEventDetails(event),
                        child: const Text('View Details'),
                      ),
                    ),
                    if (showPurchaseButton) ...[
                      SizedBox(width: ScreenUtil().setWidth(10)),
                      ElevatedButton(
                        onPressed: () => _purchaseTicket(event['id'].toString()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.oceanBlue,
                        ),
                        child: const Text('Buy Ticket'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    return Card(
      margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(15)),
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.confirmation_number, color: AppTheme.primaryYellow, size: ScreenUtil().setSp(24)),
                SizedBox(width: ScreenUtil().setWidth(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Event Ticket',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Ticket ID: ${ticket['id']}',
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(12),
                          color: AppTheme.lightText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(8),
                    vertical: ScreenUtil().setHeight(4),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Active',
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(10),
                      color: AppTheme.darkText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: ScreenUtil().setHeight(10)),
            
            Row(
              children: [
                Icon(Icons.attach_money, size: ScreenUtil().setSp(16), color: AppTheme.primaryYellow),
                SizedBox(width: ScreenUtil().setWidth(5)),
                Text(
                  '\$${(ticket['ticketPrice'] ?? 0.0).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(16),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryYellow,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    Get.dialog(
      AlertDialog(
        title: Text(event['name'] ?? 'Event'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (event['description']?.isNotEmpty == true) ...[
                Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(event['description']),
                SizedBox(height: ScreenUtil().setHeight(10)),
              ],
              
              if (event['location']?.isNotEmpty == true) ...[
                Text(
                  'Location:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(event['location']),
                SizedBox(height: ScreenUtil().setHeight(10)),
              ],
              
              Text(
                'Date & Time:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                event['date_time'] != null
                    ? DateFormat.yMMMd().add_jm().format(DateTime.parse(event['date_time']).toLocal())
                    : 'Date not available',
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              
              Text(
                'Ticket Price:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('\$${(event['ticket_price'] ?? 0.0).toStringAsFixed(2)}'),
              SizedBox(height: ScreenUtil().setHeight(10)),
              
              Text(
                'Available Tickets:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${event['available_tickets'] ?? 0}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _purchaseTicket(String eventId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Purchase Ticket'),
        content: const Text('Are you sure you want to purchase a ticket for this event?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.purchaseTicket(eventId);
              Get.back();
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('Create Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name *',
                ),
                onChanged: controller.updateEventName,
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                ),
                maxLines: 3,
                onChanged: controller.updateDescription,
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                ),
                onChanged: controller.updateLocation,
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              Obx(() => Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppTheme.lightText),
                      SizedBox(width: ScreenUtil().setWidth(10)),
                      Expanded(
                        child: Text(
                          controller.date.value != null
                              ? DateFormat.yMMMMd().format(controller.date.value!)
                              : 'Select Date *',
                          style: TextStyle(fontSize: ScreenUtil().setSp(16)),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => controller.selectDate(context),
                        child: const Text('Select'),
                      ),
                    ],
                  )),
              SizedBox(height: ScreenUtil().setHeight(10)),
              Obx(() => Row(
                    children: [
                      const Icon(Icons.access_time, color: AppTheme.lightText),
                      SizedBox(width: ScreenUtil().setWidth(10)),
                      Expanded(
                        child: Text(
                          controller.time.value != null
                              ? controller.time.value!.format(context)
                              : 'Select Time *',
                          style: TextStyle(fontSize: ScreenUtil().setSp(16)),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => controller.selectTime(context),
                        child: const Text('Select'),
                      ),
                    ],
                  )),
              SizedBox(height: ScreenUtil().setHeight(10)),
              Row(
                children: [
                  Text('Ticket Price: \$${controller.ticketPrice.value.toStringAsFixed(2)}'),
                  Expanded(
                    child: Slider(
                      value: controller.ticketPrice.value,
                      min: 0,
                      max: 1000,
                      divisions: 100,
                      activeColor: AppTheme.primaryYellow,
                      onChanged: controller.updateTicketPrice,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Max Tickets: ${controller.maxTickets.value}'),
                  Expanded(
                    child: Slider(
                      value: controller.maxTickets.value.toDouble(),
                      min: 1,
                      max: 1000,
                      divisions: 999,
                      activeColor: AppTheme.primaryYellow,
                      onChanged: (value) => controller.updateMaxTickets(value.toInt()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.createEvent();
              Get.back();
            },
            child: const Text('Create Event'),
          ),
        ],
      ),
    );
  }
} 