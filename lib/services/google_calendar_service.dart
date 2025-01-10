import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis/cloudfunctions/v2.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleCalendarService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      calendar.CalendarApi.calendarScope,
    ],
  );

  Future<AuthClient> _getAuthenticatedClient() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google kullanıcı girişi iptal edildi.');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final expiry =
        DateTime.now().add(Duration(hours: 1)).toUtc(); // UTC formatında zaman
    final accessToken = AccessToken('Bearer', googleAuth.accessToken!, expiry);

    return authenticatedClient(
      http.Client(),
      AccessCredentials(
        accessToken,
        null,
        ['https://www.googleapis.com/auth/calendar'],
      ),
    );
  }

  Future<void> addEventToGoogleCalendar(String title, String description,
      DateTime startTime, DateTime endTime, BuildContext context) async {
    try {
      final AuthClient authClient = await _getAuthenticatedClient();

      final calendarApi = calendar.CalendarApi(authClient);
      final event = calendar.Event()
        ..summary = title
        ..description = description
        ..start =
            calendar.EventDateTime(dateTime: startTime.toUtc(), timeZone: 'UTC')
        ..end =
            calendar.EventDateTime(dateTime: endTime.toUtc(), timeZone: 'UTC')
        ..reminders = calendar.EventReminders(
      useDefault: false,
      overrides: [
        calendar.EventReminder(
          method: 'popup', // veya 'email' seçeneği
          minutes: 30, // 30 dakika önce hatırlatma
        ),
      ],
    );

      await calendarApi.events.insert(event, 'primary');
      print('Etkinlik başarıyla eklendi.');

      _showSnackBar(context, '$title başarıyla Google Calendar\'a eklendi.');
    } catch (e) {
      print('Google Calendar API Hatası: $e');
      // Handle the error appropriately
    }
      }
    void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
