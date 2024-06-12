import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

void main() {
  return runApp(OnTapRestrictionForEmptyCells());
}

class OnTapRestrictionForEmptyCells extends StatefulWidget {
  @override
  OnTapRestrictionForEmptyCellsState createState() =>
      new OnTapRestrictionForEmptyCellsState();
}

class OnTapRestrictionForEmptyCellsState
    extends State<OnTapRestrictionForEmptyCells> {
  late List<TimeRegion> _regions;
  late CalendarController _controller;
  late List<DateTime> _blackoutDateCollection;
  late List<Appointment> appointments;

  @override
  void initState() {
    _controller = CalendarController();
    _regions = _getTimeRegions();
    _blackoutDateCollection = <DateTime>[];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: SafeArea(
        child: SfCalendar(
          view: CalendarView.day,
          controller: _controller,
          allowedViews: [
            CalendarView.day,
            CalendarView.week,
            CalendarView.workWeek,
            CalendarView.month,
            CalendarView.timelineDay,
            CalendarView.timelineWeek,
            CalendarView.timelineWorkWeek,
            CalendarView.timelineMonth
          ],
          dataSource: _getCalendarDataSource(),
          specialRegions: _regions,
          blackoutDates: _blackoutDateCollection,
          onViewChanged: viewChanged,
        ),
      )),
    );
  }

  _AppointmentDataSource _getCalendarDataSource() {
    appointments = <Appointment>[];
    appointments.add(Appointment(
      startTime: DateTime(2021, 2, 15, 09, 0, 0),
      endTime: DateTime(2021, 2, 15, 10, 0, 0),
      subject: 'Planning',
      color: Colors.green,
    ));

    return _AppointmentDataSource(appointments);
  }

  List<TimeRegion> _getTimeRegions() {
    _regions = <TimeRegion>[];
    return _regions;
  }

  void viewChanged(ViewChangedDetails viewChangedDetails) {
    List<DateTime> freeTimeSlot = <DateTime>[];
    var _timeSlots = 24;

    for (int i = 0; i < viewChangedDetails.visibleDates.length; i++) {
      DateTime appointment = appointments[0].startTime;
      DateTime free = viewChangedDetails.visibleDates[i];
      for (int j = 0; j < _timeSlots; j++) {
        var dateTime = free.add(Duration(hours: j));
        if (_controller.view == CalendarView.month ||
            _controller.view == CalendarView.timelineMonth) {
          if (appointment.year != dateTime.year ||
              appointment.month != dateTime.month ||
              appointment.day != dateTime.day) {
            freeTimeSlot.add(dateTime);
          }
        } else {
          if (appointment.year != dateTime.year ||
              appointment.month != dateTime.month ||
              appointment.day != dateTime.day ||
              appointment.hour != dateTime.hour ||
              appointment.minute != dateTime.minute) {
            freeTimeSlot.add(dateTime);
          }
        }
      }
    }
    if (_controller.view == CalendarView.month ||
        _controller.view == CalendarView.timelineMonth) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          _blackoutDateCollection = freeTimeSlot;
        });
      });
    } else {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          for (int i = 0; i < freeTimeSlot.length; i++) {
            setState(() {
              _regions.add(TimeRegion(
                  startTime: DateTime(
                      freeTimeSlot[i].year,
                      freeTimeSlot[i].month,
                      freeTimeSlot[i].day,
                      freeTimeSlot[i].hour,
                      0,
                      0),
                  endTime: DateTime(freeTimeSlot[i].year, freeTimeSlot[i].month,
                      freeTimeSlot[i].day, freeTimeSlot[i].hour + 1, 0, 0),
                  enablePointerInteraction: false));
            });
          }
        });
      });
    }
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
