import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/app_theme.dart';
import 'data/schedule_service.dart';

class LawyerScheduleScreen extends StatefulWidget {
  final VoidCallback onBack;
  final String currentLawyerEmail;

  const LawyerScheduleScreen({
    super.key,
    required this.onBack,
    required this.currentLawyerEmail,
  });

  @override
  State<LawyerScheduleScreen> createState() => _LawyerScheduleScreenState();
}

class _LawyerScheduleScreenState extends State<LawyerScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScheduleService _scheduleService = ScheduleService();
  bool _hasUnsavedChanges = false;
  Timer? _hideFabTimer;

  // Weekly schedule: weekday -> list of time slots
  Map<String, List<Map<String, String>>> _weeklySchedule = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };

  // Track which weekdays are enabled
  Map<String, bool> _weekdayEnabled = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadScheduleFromBackend();
    // refresh UI on tab change so FAB visibility updates
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadScheduleFromBackend() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await _scheduleService.getSchedule(widget.currentLawyerEmail);
      // Response format: { email, weekly_schedule: [{ weekday, slots: [{start, end}] }] }
      // This is now a recurring weekly pattern
      if (response['weekly_schedule'] != null) {
        final weeklySchedule = response['weekly_schedule'] as List;
        // Clear existing schedule
        _weeklySchedule = {
          'Monday': [],
          'Tuesday': [],
          'Wednesday': [],
          'Thursday': [],
          'Friday': [],
          'Saturday': [],
          'Sunday': [],
        };
        _weekdayEnabled = {
          'Monday': false,
          'Tuesday': false,
          'Wednesday': false,
          'Thursday': false,
          'Friday': false,
          'Saturday': false,
          'Sunday': false,
        };

        for (var daySchedule in weeklySchedule) {
          final weekday = daySchedule['weekday'] as String;
          final slots = daySchedule['slots'] as List;

          if (_weeklySchedule.containsKey(weekday)) {
            _weekdayEnabled[weekday] = true;
            _weeklySchedule[weekday] = slots
                .map((s) => {
                      'start': s['start'].toString(),
                      'end': s['end'].toString(),
                    })
                .toList();
          }
        }
      }
    } catch (e) {
      // 404 or other error - keep all weekdays unselected
      print('No schedule found or error loading: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _hasUnsavedChanges = false; // loaded schedule is the source of truth
      });
    }
  }

  @override
  void dispose() {
    _hideFabTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAppointmentsTab(),
                    _buildAvailabilityTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: (_tabController.index == 1 && _hasUnsavedChanges)
            ? FloatingActionButton.extended(
                key: const ValueKey('save-fab'),
                onPressed: _saveSchedule,
                backgroundColor: AppTheme.primaryBlue,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('Save changes',
                    style: TextStyle(color: Colors.white)),
              )
            : const SizedBox.shrink(
                key: ValueKey('no-fab'),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.accentBlue],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: widget.onBack,
              ),
              const Expanded(
                child: Text(
                  'Schedule & Availability',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Save/calendar icons removed; saving is available via inline FAB when changes exist
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: _buildHeaderStat('5', 'Today', Icons.today),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: _buildHeaderStat('23', 'This Week', Icons.date_range),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: _buildHeaderStat(
                      '87', 'This Month', Icons.calendar_today),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(minHeight: 72),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // remove explicit border to avoid horizontal divider
        // color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorPadding:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        labelPadding: EdgeInsets.zero,
        labelColor: Colors.white,
        tabs: const [
          Tab(
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Text('Appointments'))),
          Tab(
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Text('Availability'))),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeekCalendar(),
          const SizedBox(height: 24),
          Text(
            'Today\'s Schedule - Oct 12, 2025',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildAppointmentCard(
            '9:00 AM - 10:00 AM',
            'John Mitchell',
            'Criminal Defense - Case Review',
            'Video Call',
            AppTheme.primaryBlue,
            'confirmed',
          ),
          _buildAppointmentCard(
            '11:00 AM - 12:00 PM',
            'Maria Garcia',
            'Family Law - Divorce Consultation',
            'In-Person',
            AppTheme.accentBlue,
            'confirmed',
          ),
          _buildAppointmentCard(
            '2:00 PM - 3:00 PM',
            'David Lee',
            'Property Dispute - Initial Meeting',
            'Phone Call',
            Colors.orange,
            'pending',
          ),
          _buildAppointmentCard(
            '4:00 PM - 5:00 PM',
            'Sarah Williams',
            'Contract Review',
            'Video Call',
            AppTheme.primaryBlue,
            'confirmed',
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'October 2025',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDayItem('Mon', '10', false, 3),
              _buildDayItem('Tue', '11', false, 5),
              _buildDayItem('Wed', '12', true, 5),
              _buildDayItem('Thu', '13', false, 4),
              _buildDayItem('Fri', '14', false, 6),
              _buildDayItem('Sat', '15', false, 2),
              _buildDayItem('Sun', '16', false, 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(
      String day, String date, bool isSelected, int appointments) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          if (appointments > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : AppTheme.accentBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$appointments',
                style: TextStyle(
                  fontSize: 10,
                  color:
                      isSelected ? AppTheme.primaryBlue : AppTheme.accentBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(
    String time,
    String client,
    String description,
    String type,
    Color color,
    String status,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: color),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == 'confirmed'
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status == 'confirmed' ? 'Confirmed' : 'Pending',
                            style: TextStyle(
                              fontSize: 11,
                              color: status == 'confirmed'
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      client,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.videocam, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                type,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('Reschedule'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('Start'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // _showSetAvailabilityDialog removed; use inline Add Time Slot actions

  Future<void> _addTimeSlot(String weekday) async {
    final start = await showTimePicker(
        context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
    if (start == null) return;

    final end = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: start.hour + 1, minute: start.minute));
    if (end == null) return;

    final slot = {
      'start':
          '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
      'end':
          '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}'
    };

    setState(() {
      _weeklySchedule[weekday]!.add(slot);
      _weekdayEnabled[weekday] = true;
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _editTimeSlot(String weekday, int index) async {
    final currentSlot = _weeklySchedule[weekday]![index];
    final currentStart = TimeOfDay(
      hour: int.parse(currentSlot['start']!.split(':')[0]),
      minute: int.parse(currentSlot['start']!.split(':')[1]),
    );
    final currentEnd = TimeOfDay(
      hour: int.parse(currentSlot['end']!.split(':')[0]),
      minute: int.parse(currentSlot['end']!.split(':')[1]),
    );

    final start =
        await showTimePicker(context: context, initialTime: currentStart);
    if (start == null) return;

    final end = await showTimePicker(context: context, initialTime: currentEnd);
    if (end == null) return;

    final slot = {
      'start':
          '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
      'end':
          '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}'
    };

    setState(() {
      _weeklySchedule[weekday]![index] = slot;
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _saveSchedule() async {
    // Convert weekday-based schedule to weekly_schedule format for backend
    // This creates a recurring weekly pattern
    final List<Map<String, dynamic>> weeklyScheduleList = [];

    _weeklySchedule.forEach((weekday, slots) {
      if (_weekdayEnabled[weekday]! && slots.isNotEmpty) {
        weeklyScheduleList.add({
          'weekday': weekday,
          'slots': slots,
        });
      }
    });

    final payload = {
      'email': widget.currentLawyerEmail,
      'weekly_schedule': weeklyScheduleList,
    };

    try {
      await _scheduleService.saveSchedule(widget.currentLawyerEmail, payload);
      if (mounted) {
        // show small confirmation and hide FAB after a short delay
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All changes saved'),
            backgroundColor: AppTheme.primaryBlue,
            duration: Duration(milliseconds: 1200),
          ),
        );
        // delay clearing the unsaved flag so the user sees the confirmation
        _hideFabTimer?.cancel();
        _hideFabTimer = Timer(const Duration(milliseconds: 1200), () {
          if (mounted) setState(() => _hasUnsavedChanges = false);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save schedule: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAvailabilityTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primaryBlue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Set your weekly availability to help clients book consultations at convenient times.',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Weekly Schedule',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._weeklySchedule.keys.map((day) => _buildDaySchedule(
                day,
                _weeklySchedule[day]!,
                _weekdayEnabled[day]!,
              )),
        ],
      ),
    );
  }

  Widget _buildDaySchedule(
      String day, List<Map<String, String>> slots, bool isAvailable) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Switch(
                value: isAvailable,
                onChanged: (val) {
                  setState(() {
                    _weekdayEnabled[day] = val;
                    // mark unsaved for both enable/disable
                    if (!val) {
                      // Clear slots when disabled
                      _weeklySchedule[day] = [];
                    }
                    _hasUnsavedChanges = true;
                  });
                },
                activeThumbColor: AppTheme.primaryBlue,
              ),
            ],
          ),
          if (isAvailable && slots.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...slots.asMap().entries.map((entry) {
              final index = entry.key;
              final slot = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      '${slot['start']} - ${slot['end']}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () => _editTimeSlot(day, index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, size: 18, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _weeklySchedule[day]!.removeAt(index);
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _addTimeSlot(day),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Time Slot'),
            ),
          ],
          if (isAvailable && slots.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No time slots set',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _addTimeSlot(day),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Time Slot'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // old dialog removed — using custom time-picker based dialog in new implementation
}
