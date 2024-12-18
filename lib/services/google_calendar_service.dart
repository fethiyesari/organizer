import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleCalendarService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      calendar.CalendarApi.calendarScope,
    ],
  );

  Future<void> addEventToGoogleCalendar(String title, String description,
      DateTime startTime, DateTime endTime) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google kullanıcı girişi iptal edildi.');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthClient authClient = authenticatedClient(
        http.Client(),
        AccessCredentials(
          AccessToken('Bearer', googleAuth.accessToken!,
              DateTime.now().add(Duration(hours: 1))),
          null,
          ['https://www.googleapis.com/auth/calendar'],
        ),
      );

      final calendarApi = calendar.CalendarApi(authClient);
      final event = calendar.Event()
        ..summary = title
        ..description = description
        ..start = calendar.EventDateTime(dateTime: startTime, timeZone: 'GMT')
        ..end = calendar.EventDateTime(dateTime: endTime, timeZone: 'GMT');

      await calendarApi.events.insert(event, 'primary');
      print('Etkinlik başarıyla eklendi.');
    } catch (e) {
      print('Google Calendar API Hatası: $e');
    }
  }
}
