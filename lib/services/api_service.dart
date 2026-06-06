import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/therapist.dart';
import '../models/booking.dart';
import '../models/trace_entry.dart';
import '../models/user_profile.dart';
import '../models/chat_message.dart';
import '../models/service_provider.dart';
import '../models/service_booking.dart';

class FindResult {
  final List<Therapist> therapists;
  final String traceId;
  final Map<String, dynamic> intent;
  FindResult({required this.therapists, required this.traceId, required this.intent});
}

class BookingResult {
  final Booking booking;
  final String traceId;
  final String parentNotification;
  final List<Map<String, dynamic>> followupEvents;
  BookingResult({required this.booking, required this.traceId, required this.parentNotification, required this.followupEvents});
}

// ─── Mock therapist data ──────────────────────────────────────────────────
const _kTherapistsJson = r'''[
  {"id":"t001","name":"Dr. Mehwish Iqbal","gender":"female","specializations":["speech_therapy","language_delay"],"qualifications":["M.Sc Speech-Language Pathology, KIBGE"],"qualification_level":"masters","verified":true,"city":"Lahore","area":"Gulberg","lat":31.517,"lng":74.355,"rating":4.5,"review_count":38,"last_review_days_ago":11,"on_time_rate":0.89,"cancellation_rate":0.06,"base_price":2500,"age_ranges":["preschool","school_age"],"experience_years":5,"available_slots":["2026-07-10T10:00:00","2026-07-12T10:00:00","2026-07-15T15:00:00","2026-07-18T15:00:00","2026-07-20T10:00:00"],"bio":"Specialist in speech-language delays and articulation disorders for school-age children.","languages":["urdu","english"]},
  {"id":"t002","name":"Dr. Bilal Hassan","gender":"male","specializations":["occupational_therapy","sensory_integration"],"qualifications":["M.Phil Occupational Therapy, PIRS"],"qualification_level":"mphil","verified":true,"city":"Lahore","area":"DHA","lat":31.4707,"lng":74.4036,"rating":4.7,"review_count":54,"last_review_days_ago":4,"on_time_rate":0.93,"cancellation_rate":0.04,"base_price":3200,"age_ranges":["preschool","school_age","teen"],"experience_years":7,"available_slots":["2026-07-10T11:00:00","2026-07-13T11:00:00","2026-07-17T16:00:00","2026-07-20T11:00:00"],"bio":"Sensory integration specialist working with children with autism and SPD.","languages":["urdu","english","punjabi"]},
  {"id":"t003","name":"Ms. Nida Rauf","gender":"female","specializations":["aba_therapy","autism_specialist"],"qualifications":["B.Sc Applied Psychology, FCC"],"qualification_level":"bachelors","verified":false,"city":"Lahore","area":"Gulberg","lat":31.524,"lng":74.361,"rating":4.0,"review_count":17,"last_review_days_ago":19,"on_time_rate":0.78,"cancellation_rate":0.14,"base_price":2200,"age_ranges":["toddler","preschool"],"experience_years":2,"available_slots":["2026-07-11T14:00:00","2026-07-14T14:00:00","2026-07-18T14:00:00"],"bio":"Junior ABA practitioner under BCBA supervision; gentle approach for young children.","languages":["urdu","english"]},
  {"id":"t004","name":"Dr. Faiza Tariq","gender":"female","specializations":["special_education","learning_disability"],"qualifications":["M.Phil Special Education, PU"],"qualification_level":"mphil","verified":true,"city":"Lahore","area":"Johar Town","lat":31.4697,"lng":74.2728,"rating":4.6,"review_count":42,"last_review_days_ago":7,"on_time_rate":0.91,"cancellation_rate":0.05,"base_price":2800,"age_ranges":["school_age","teen"],"experience_years":8,"available_slots":["2026-07-10T09:00:00","2026-07-13T09:00:00","2026-07-17T09:00:00"],"bio":"Resource teacher specializing in dyslexia and learning disabilities.","languages":["urdu","english"]},
  {"id":"t005","name":"Mr. Asad Mahmood","gender":"male","specializations":["behavioral_therapy","adhd_specialist"],"qualifications":["MS Clinical Psychology, GCU"],"qualification_level":"masters","verified":false,"city":"Lahore","area":"Model Town","lat":31.4837,"lng":74.3225,"rating":4.2,"review_count":23,"last_review_days_ago":14,"on_time_rate":0.84,"cancellation_rate":0.1,"base_price":2600,"age_ranges":["school_age","teen"],"experience_years":4,"available_slots":["2026-07-11T16:00:00","2026-07-14T16:00:00","2026-07-18T16:00:00"],"bio":"CBT-based behavioral interventions for ADHD and oppositional behavior.","languages":["urdu","english"]},
  {"id":"t006","name":"Ms. Hina Aslam","gender":"female","specializations":["physiotherapy_special_needs","cerebral_palsy"],"qualifications":["DPT, RCRS"],"qualification_level":"bachelors","verified":true,"city":"Lahore","area":"DHA","lat":31.472,"lng":74.408,"rating":4.4,"review_count":31,"last_review_days_ago":6,"on_time_rate":0.88,"cancellation_rate":0.07,"base_price":3000,"age_ranges":["toddler","preschool","school_age"],"experience_years":6,"available_slots":["2026-07-10T13:00:00","2026-07-13T13:00:00","2026-07-16T13:00:00"],"bio":"Pediatric physio for cerebral palsy, hypotonia, and motor delays.","languages":["urdu","english","punjabi"]},
  {"id":"t007","name":"Dr. Ayesha Khan","gender":"female","specializations":["speech_therapy","language_delay","autism_speech"],"qualifications":["M.Phil Speech-Language Pathology, KIBGE"],"qualification_level":"mphil","verified":true,"city":"Lahore","area":"Gulberg","lat":31.5204,"lng":74.3587,"rating":4.8,"review_count":64,"last_review_days_ago":5,"on_time_rate":0.94,"cancellation_rate":0.03,"base_price":2800,"age_ranges":["preschool","school_age"],"experience_years":4,"available_slots":["2026-07-09T16:00:00","2026-07-12T16:00:00","2026-07-16T16:00:00"],"bio":"Specialized in pediatric speech-language therapy for children with autism and speech delays.","languages":["urdu","english","punjabi"]},
  {"id":"t008","name":"Dr. Sara Ahmed","gender":"female","specializations":["speech_therapy","articulation"],"qualifications":["M.Sc Speech-Language Pathology, KIBGE"],"qualification_level":"masters","verified":true,"city":"Lahore","area":"Gulberg","lat":31.518,"lng":74.362,"rating":4.7,"review_count":48,"last_review_days_ago":8,"on_time_rate":0.92,"cancellation_rate":0.04,"base_price":2700,"age_ranges":["preschool","school_age"],"experience_years":5,"available_slots":["2026-07-09T16:00:00","2026-07-12T16:00:00","2026-07-15T16:00:00"],"bio":"Speech-language pathologist focused on articulation and fluency.","languages":["urdu","english"]},
  {"id":"t013","name":"Dr. Saima Qureshi","gender":"female","specializations":["speech_therapy","language_delay"],"qualifications":["M.Phil SLP, JSMU"],"qualification_level":"mphil","verified":true,"city":"Karachi","area":"Clifton","lat":24.8138,"lng":67.0299,"rating":4.8,"review_count":71,"last_review_days_ago":3,"on_time_rate":0.95,"cancellation_rate":0.02,"base_price":4000,"age_ranges":["preschool","school_age","teen"],"experience_years":9,"available_slots":["2026-07-10T15:00:00","2026-07-13T15:00:00","2026-07-16T15:00:00"],"bio":"Senior speech-language pathologist; bilingual therapy in Urdu and English.","languages":["urdu","english","sindhi"]},
  {"id":"t019","name":"Dr. Anum Pirzada","gender":"female","specializations":["occupational_therapy","adhd_specialist","sensory_integration"],"qualifications":["M.Phil OT, DUHS"],"qualification_level":"mphil","verified":true,"city":"Karachi","area":"DHA","lat":24.799,"lng":67.062,"rating":4.9,"review_count":82,"last_review_days_ago":2,"on_time_rate":0.96,"cancellation_rate":0.02,"base_price":4500,"age_ranges":["school_age","teen"],"experience_years":10,"available_slots":["2026-07-10T17:00:00","2026-07-12T17:00:00","2026-07-15T17:00:00"],"bio":"Senior OT specializing in ADHD and executive function support.","languages":["urdu","english"]},
  {"id":"t023","name":"Dr. Maryam Akhtar","gender":"female","specializations":["aba_therapy","autism","early_intervention"],"qualifications":["M.Phil ABA, QAU"],"qualification_level":"mphil","verified":true,"city":"Islamabad","area":"F-8","lat":33.7077,"lng":73.0563,"rating":4.8,"review_count":67,"last_review_days_ago":4,"on_time_rate":0.95,"cancellation_rate":0.03,"base_price":4000,"age_ranges":["preschool","school_age"],"experience_years":8,"available_slots":["2026-07-10T11:00:00","2026-07-13T11:00:00","2026-07-16T11:00:00"],"bio":"Comprehensive ABA programming for children with autism aged 4-10.","languages":["urdu","english"]},
  {"id":"t026","name":"Dr. Aiman Siddiqui","gender":"female","specializations":["speech_therapy","language_delay","autism_speech"],"qualifications":["M.Phil SLP, QAU"],"qualification_level":"mphil","verified":true,"city":"Islamabad","area":"G-9","lat":33.6932,"lng":73.0479,"rating":4.7,"review_count":49,"last_review_days_ago":5,"on_time_rate":0.93,"cancellation_rate":0.04,"base_price":3200,"age_ranges":["toddler","preschool","school_age"],"experience_years":6,"available_slots":["2026-07-10T14:00:00","2026-07-13T14:00:00","2026-07-16T14:00:00"],"bio":"Speech-language pathologist; specialist in late talkers and autism communication.","languages":["urdu","english"]},
  {"id":"t031","name":"Ali Transport Service","gender":"male","specializations":["accessible_transport"],"qualifications":["Certified Wheelchair Van Operator"],"qualification_level":"bachelors","verified":true,"city":"Lahore","area":"Gulberg","lat":31.52,"lng":74.35,"rating":4.6,"review_count":120,"last_review_days_ago":2,"on_time_rate":0.95,"cancellation_rate":0.02,"base_price":1500,"age_ranges":["preschool","school_age","teen"],"experience_years":5,"available_slots":["2026-07-10T08:00:00","2026-07-11T08:00:00"],"bio":"Wheelchair accessible transport for disabled individuals.","languages":["urdu","punjabi"]},
  {"id":"t032","name":"Sana Interpreter","gender":"female","specializations":["sign_language_interpreter"],"qualifications":["Diploma in Sign Language"],"qualification_level":"bachelors","verified":true,"city":"Islamabad","area":"F-8","lat":33.7,"lng":73.05,"rating":4.9,"review_count":45,"last_review_days_ago":5,"on_time_rate":0.98,"cancellation_rate":0.01,"base_price":2000,"age_ranges":["school_age","teen"],"experience_years":6,"available_slots":["2026-07-10T10:00:00","2026-07-12T14:00:00"],"bio":"Certified sign language interpreter for doctor visits, schools, and events.","languages":["urdu","english","sign_language"]},
  {"id":"t033","name":"CareHome Nursing","gender":"female","specializations":["home_nursing","disability_support_worker"],"qualifications":["BSc Nursing"],"qualification_level":"bachelors","verified":true,"city":"Karachi","area":"DHA","lat":24.8,"lng":67.05,"rating":4.7,"review_count":89,"last_review_days_ago":1,"on_time_rate":0.92,"cancellation_rate":0.05,"base_price":3000,"age_ranges":["preschool","school_age","teen"],"experience_years":8,"available_slots":["2026-07-10T09:00:00","2026-07-11T09:00:00"],"bio":"Professional home nursing and caregiving for disabled children and adults.","languages":["urdu","english","sindhi"]},
  {"id":"t034","name":"Ahsan Wheelchair Repair","gender":"male","specializations":["wheelchair_repair"],"qualifications":["Mechanical Diploma"],"qualification_level":"bachelors","verified":true,"city":"Lahore","area":"Johar Town","lat":31.46,"lng":74.27,"rating":4.5,"review_count":34,"last_review_days_ago":10,"on_time_rate":0.9,"cancellation_rate":0.08,"base_price":1000,"age_ranges":["preschool","school_age","teen"],"experience_years":10,"available_slots":["2026-07-10T12:00:00","2026-07-13T15:00:00"],"bio":"Expert wheelchair and mobility scooter repair at your doorstep.","languages":["urdu","punjabi"]}
]''';

const _kProvidersJson = r'''[
  {"id":"p001","name":"Khan Plumbing Services","category":"plumbing","city":"Lahore","area":"Gulberg","rating":4.5,"review_count":89,"base_price":1500,"experience_years":10,"verified":true,"bio":"Expert plumbers for all household needs.","available_slots":["2026-07-10T09:00:00","2026-07-11T14:00:00"],"on_time_rate":0.92},
  {"id":"p002","name":"FastFix Electrician","category":"electrician","city":"Lahore","area":"DHA","rating":4.7,"review_count":112,"base_price":2000,"experience_years":8,"verified":true,"bio":"Certified electricians for wiring, panels, and repairs.","available_slots":["2026-07-10T10:00:00","2026-07-12T10:00:00"],"on_time_rate":0.95},
  {"id":"p003","name":"CoolBreeze AC Services","category":"ac_repair","city":"Lahore","area":"Johar Town","rating":4.6,"review_count":67,"base_price":2500,"experience_years":6,"verified":true,"bio":"AC installation, repair, and servicing.","available_slots":["2026-07-11T11:00:00","2026-07-13T15:00:00"],"on_time_rate":0.9},
  {"id":"p004","name":"Star Home Tutor","category":"tutor","city":"Karachi","area":"DHA","rating":4.8,"review_count":45,"base_price":1800,"experience_years":5,"verified":true,"bio":"Home tutors for all subjects, grades 1-12.","available_slots":["2026-07-10T15:00:00","2026-07-12T17:00:00"],"on_time_rate":0.94},
  {"id":"p005","name":"CleanHome Maid Service","category":"maid","city":"Islamabad","area":"F-8","rating":4.4,"review_count":78,"base_price":1200,"experience_years":7,"verified":true,"bio":"Reliable household cleaning and maid service.","available_slots":["2026-07-10T08:00:00","2026-07-11T08:00:00"],"on_time_rate":0.88}
]''';

// ─── Helpers ──────────────────────────────────────────────────────────────

Map<String, dynamic> _parseIntent(String msg) {
  final m = msg.toLowerCase();
  String serviceType = 'speech_therapy';
  if (m.contains('occupational') || m.contains(' ot ') || m.contains('sensory') || m.contains('handwriting')) {
    serviceType = 'occupational_therapy';
  } else if (m.contains('aba') || m.contains('behavior')) {
    serviceType = 'aba_therapy';
  } else if (m.contains('special education') || m.contains('learning')) {
    serviceType = 'special_education';
  } else if (m.contains('physio') || m.contains('physical therap')) {
    serviceType = 'physiotherapy_special_needs';
  } else if (m.contains('transport') || m.contains('van ') || (m.contains('wheelchair') && m.contains('transport'))) {
    serviceType = 'accessible_transport';
  } else if (m.contains('sign language') || m.contains('interpreter')) {
    serviceType = 'sign_language_interpreter';
  } else if (m.contains('nursing') || m.contains('nurse')) {
    serviceType = 'home_nursing';
  } else if (m.contains('speech') || m.contains('bolan') || m.contains('zubaan')) {
    serviceType = 'speech_therapy';
  }
  String condition = 'autism';
  if (m.contains('adhd')) condition = 'adhd';
  else if (m.contains('cerebral palsy') || m.contains(' cp ')) condition = 'cerebral_palsy';
  else if (m.contains('down syndrome')) condition = 'down_syndrome';
  else if (m.contains('speech delay') || m.contains('late talker')) condition = 'speech_delay';

  String city = 'Lahore';
  if (m.contains('karachi')) city = 'Karachi';
  if (m.contains('islamabad') || m.contains('isb')) city = 'Islamabad';

  return {'service_type': serviceType, 'condition': condition, 'city': city, 'confidence': 0.85, 'needs_clarification': false};
}

List<Therapist> _filterAndRank(Map<String, dynamic> intent) {
  final all = (jsonDecode(_kTherapistsJson) as List)
      .map((j) => Therapist.fromJson(j as Map<String, dynamic>))
      .toList();
  final city = intent['city'] as String? ?? 'Lahore';
  final service = (intent['service_type'] as String? ?? '').split('_')[0];
  var filtered = all.where((t) => t.city == city).toList();
  if (filtered.isEmpty) filtered = List.from(all);
  filtered.sort((a, b) {
    final aM = a.specializations.any((s) => s.contains(service)) ? 1 : 0;
    final bM = b.specializations.any((s) => s.contains(service)) ? 1 : 0;
    if (aM != bM) return bM - aM;
    return b.rating.compareTo(a.rating);
  });
  return filtered.take(6).toList();
}

// ─── In-memory stores ─────────────────────────────────────────────────────

final List<Booking> _mockBookings = [];
int _bookingCounter = 1000;
final Map<String, List<ChatMessage>> _chatStore = {};

// ─── ApiService ───────────────────────────────────────────────────────────

class ApiService {
  static const String baseUrl = 'mock://noorai-demo';
  static String absoluteUrl(String u) => u;

  Future<bool> refreshSession() async => true;
  Future<void> logoutServer() async {}

  Future<FindResult> findTherapists(String userMessage) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final intent = _parseIntent(userMessage);
    return FindResult(
      therapists: _filterAndRank(intent),
      traceId: 'mock-trace-${DateTime.now().millisecondsSinceEpoch}',
      intent: intent,
    );
  }

  Future<BookingResult> bookTherapist({
    required String therapistId,
    required String slot,
    required Map<String, dynamic> intent,
    int sessionsCount = 2,
    String? traceId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _bookingCounter++;
    final bookingId = 'BK$_bookingCounter';
    final slotDt = DateTime.tryParse(slot) ?? DateTime.now().add(const Duration(days: 1));
    final price = (intent['base_price'] as int? ?? 3000);

    final sessions = List.generate(sessionsCount, (i) {
      final d = slotDt.add(Duration(days: i * 7));
      return BookingSession(
        date: '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}',
        time: '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}',
        durationMin: 45,
        status: 'confirmed',
      );
    });

    final booking = Booking(
      bookingId: bookingId,
      therapistId: therapistId,
      userId: 'u-demo-001',
      sessions: sessions,
      totalPrice: price * sessionsCount,
      confirmationCode: 'NA-$bookingId',
      status: 'confirmed',
      createdAt: DateTime.now().toIso8601String(),
    );
    _mockBookings.add(booking);

    return BookingResult(
      booking: booking,
      traceId: traceId ?? 'mock-trace',
      parentNotification: 'Booking confirmed! Your first session is on ${sessions[0].formattedDate} at ${sessions[0].time}.',
      followupEvents: [
        {'type': 'session_reminder', 'when': 'T-24h', 'message': 'Kal session hai. Tayyar rahein!'},
        {'type': 'session_reminder', 'when': 'T-1h', 'message': 'Session 1 ghante mein hai.'},
        {'type': 'feedback_request', 'when': 'T+1h', 'message': 'Session kaisa raha? Rating dein.'},
        {'type': 'followup_check', 'when': 'T+3d', 'message': 'Bachy ki progress kaisi hai?'},
        {'type': 'rebooking_prompt', 'when': 'T+7d', 'message': 'Agla session book karein?'},
      ],
    );
  }

  Future<TraceLog?> getTrace(String traceId) async {
    final now = DateTime.now().toIso8601String();
    return TraceLog(
      traceId: traceId,
      createdAt: now,
      userMessage: 'Demo query',
      entries: [
        TraceEntry(agent: 'IntentAgent', startedAt: now, durationMs: 320, inputSummary: 'User query in Urdu/English', reasoning: 'Extracted service type, condition, city, and urgency from natural language', outputSummary: 'speech_therapy • autism • Lahore • confidence: 0.85'),
        TraceEntry(agent: 'DiscoveryAgent', startedAt: now, durationMs: 145, inputSummary: 'Structured intent', reasoning: 'Filtered therapist database by city and specialization', outputSummary: 'Found 18 candidates in Lahore'),
        TraceEntry(agent: 'RankingAgent', startedAt: now, durationMs: 89, inputSummary: '18 candidates', reasoning: 'Applied 8-factor scoring: rating, on-time rate, experience, distance, gender pref, budget fit, availability, reviews', outputSummary: 'Top 6 ranked — Dr. Ayesha Khan scored 91/100'),
        TraceEntry(agent: 'PricingAgent', startedAt: now, durationMs: 62, inputSummary: 'Top 6 therapists', reasoning: 'Dynamic pricing based on demand, session count, and area surcharge', outputSummary: 'Prices finalized: PKR 2800–3200/session'),
      ],
    );
  }

  Future<Map<String, dynamic>?> getBaselineComparison(String userMessage) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return {
      'ai_result': {'time_seconds': 2.3, 'results_count': 6, 'top_match_score': 91},
      'baseline_result': {'time_seconds': 45.0, 'results_count': 3, 'top_match_score': 62},
      'improvement': {'speed': '19x faster', 'quality': '47% better match'},
    };
  }

  Future<ServiceFindResult> findServices(String userMessage) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final all = (jsonDecode(_kProvidersJson) as List)
        .map((j) => ServiceProvider.fromJson(j as Map<String, dynamic>))
        .toList();
    return ServiceFindResult(
      providers: all,
      traceId: 'mock-svc-${DateTime.now().millisecondsSinceEpoch}',
      intent: {'user_message': userMessage, 'confidence': 0.80},
    );
  }

  Future<ServiceBookingResult> bookService({
    required String providerId,
    String? slot,
    required Map<String, dynamic> intent,
    String? traceId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _bookingCounter++;
    final bookingId = 'SB$_bookingCounter';
    final slotStr = slot ?? DateTime.now().add(const Duration(days: 1)).toIso8601String();
    final slotDt = DateTime.tryParse(slotStr) ?? DateTime.now().add(const Duration(days: 1));
    final booking = ServiceBooking(
      bookingId: bookingId,
      providerName: intent['provider_name'] as String? ?? 'Service Provider',
      category: intent['category'] as String? ?? 'general',
      date: '${slotDt.year}-${slotDt.month.toString().padLeft(2,'0')}-${slotDt.day.toString().padLeft(2,'0')}',
      time: '${slotDt.hour.toString().padLeft(2,'0')}:${slotDt.minute.toString().padLeft(2,'0')}',
      price: (intent['base_price'] as int? ?? 2000).toDouble(),
      confirmationCode: 'SVC-$bookingId',
      status: 'confirmed',
    );
    return ServiceBookingResult(
      booking: booking,
      traceId: traceId ?? 'mock-svc-trace',
      userMessage: 'Service booking confirmed! Provider will arrive at the scheduled time.',
      followupEvents: [
        {'type': 'reminder', 'when': 'T-2h', 'message': 'Service provider 2 ghante mein aa raha hai.'},
      ],
    );
  }

  Future<Map<String, dynamic>?> submitDispute({
    required String bookingId,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'dispute_id': 'D${DateTime.now().millisecondsSinceEpoch}',
      'status': 'received',
      'message': 'Aapka dispute mil gaya. Humari team 24 ghante mein review karegi.',
      'resolution': 'Hum aapko ek alternative therapist bina extra charge ke dhundhenge.',
    };
  }

  Future<({UserProfile user, String token, String refreshToken})> register({
    required String email,
    required String password,
    required String name,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final user = UserProfile(
      userId: 'u${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      createdAt: DateTime.now().toIso8601String(),
    );
    return (user: user, token: 'mock-token-demo', refreshToken: 'mock-refresh-demo');
  }

  Future<({UserProfile user, String token, String refreshToken})> login({
    required String email,
    required String password,
    bool remember = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final user = UserProfile(
      userId: 'u-demo-001',
      email: email,
      name: email.split('@')[0],
      createdAt: DateTime.now().toIso8601String(),
    );
    return (user: user, token: 'mock-token-demo', refreshToken: 'mock-refresh-demo');
  }

  Future<UserProfile> updateProfile(Map<String, dynamic> patch) async {
    return UserProfile(
      userId: 'u-demo-001',
      email: patch['email'] as String? ?? 'demo@noorai.pk',
      name: patch['name'] as String? ?? 'Demo User',
      phone: patch['phone'] as String?,
      childName: patch['child_name'] as String?,
      childAge: patch['child_age'] as int?,
      childCondition: patch['child_condition'] as String?,
      city: patch['city'] as String?,
      area: patch['area'] as String?,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  Future<List<Booking>> listMyBookings() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockBookings);
  }

  Future<List<Map<String, dynamic>>> listChatThreads() async {
    return _chatStore.keys
        .map((id) => {'therapist_id': id, 'last_message': 'Hello!'})
        .toList();
  }

  Future<List<ChatMessage>> listMessages(String therapistId) async {
    return _chatStore[therapistId] ?? [];
  }

  Future<ChatMessage?> sendText(String therapistId, String text) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final msg = ChatMessage(
      messageId: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      threadId: therapistId,
      userId: 'u-demo-001',
      therapistId: therapistId,
      sender: 'user',
      kind: 'text',
      text: text,
      createdAt: DateTime.now(),
    );
    _chatStore.putIfAbsent(therapistId, () => []).add(msg);
    return msg;
  }

  Future<ChatMessage?> sendVoiceNote({
    required String therapistId,
    required String filePath,
    required int durationMs,
  }) async {
    debugPrint('[MockApi] Voice note — demo mode, not uploaded');
    return null;
  }
}
