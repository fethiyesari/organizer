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
      DateTime startTime, DateTime endTime) async {
    try {
      final AuthClient authClient = await _getAuthenticatedClient();

      final calendarApi = calendar.CalendarApi(authClient);
      final event = calendar.Event()
        ..summary = title
        ..description = description
        ..start =
            calendar.EventDateTime(dateTime: startTime.toUtc(), timeZone: 'UTC')
        ..end =
            calendar.EventDateTime(dateTime: endTime.toUtc(), timeZone: 'UTC');

      await calendarApi.events.insert(event, 'primary');
      print('Etkinlik başarıyla eklendi.');
    } catch (e) {
      print('Google Calendar API Hatası: $e');
      // Handle the error appropriately
    }
  }
}
