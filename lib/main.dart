// ============================================================================
// HomeDirect — main.dart  (SINGLE FILE)
// Direct-to-owner rental housing marketplace. Roles: tenant + owner.
// (Admin lives in a SEPARATE project: admin/admin.html — not in this app.)
//
// This is the REAL product. Backend-dependent features that still need an
// external service are marked with:  // ===== SPOT: ... =====
//
// Until you paste your Supabase keys in AppConfig below, the app runs in
// DEMO MODE with built-in sample listings so every screen still works.
// ============================================================================
//
// pubspec.yaml dependency (only one):
//   dependencies:
//     flutter:
//       sdk: flutter
//     supabase_flutter: ^2.5.6
//
// ============================================================================

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================================
// 1. CONFIG  — paste your Supabase project values here after you deploy.
//    Find them in Supabase → Project Settings → API.
// ============================================================================
class AppConfig {
  // ===== SPOT: Supabase credentials =========================================
  static const String supabaseUrl = 'https://kyeyreriaiydbnnyiobm.supabase.co';        // e.g. https://abcd.supabase.co
  static const String supabaseAnonKey = 'sb_publishable_ktxYlImZtqLR4-FzlyZx3A_oTjX4h7v';
  // ==========================================================================

  /// True once real keys have been pasted above.
  static bool get isConfigured =>
      !supabaseUrl.startsWith('YOUR_') && !supabaseAnonKey.startsWith('YOUR_');
}

/// Safe handle to the Supabase client (null when running in demo mode).
SupabaseClient? get sb =>
    AppConfig.isConfigured ? Supabase.instance.client : null;

// ============================================================================
// 2. DESIGN TOKENS  — one calm, trustworthy identity: deep teal + sunlit gold.
// ============================================================================
class C {
  static const ink = Color(0xFF0E1B1A);      // near-black text
  static const teal = Color(0xFF0B4F4A);     // brand
  static const tealDeep = Color(0xFF063733);
  static const tealLight = Color(0xFF14746F);
  static const gold = Color(0xFFF4B740);     // accent / CTA highlight
  static const goldDeep = Color(0xFFE39A16);
  static const bg = Color(0xFFF6F8F7);       // cool off-white
  static const surface = Colors.white;
  static const muted = Color(0xFF6B7C7A);
  static const line = Color(0xFFE4EAE8);
  static const danger = Color(0xFFC0392B);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tealDeep, teal, tealLight],
  );
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: C.teal,
    primary: C.teal,
    secondary: C.gold,
    surface: C.surface,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: C.bg,
    fontFamily: null, // system font; add google_fonts later if you want
    appBarTheme: const AppBarTheme(
      backgroundColor: C.bg,
      foregroundColor: C.ink,
      elevation: 0,
      centerTitle: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: C.teal,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: C.teal,
        minimumSize: const Size.fromHeight(54),
        side: const BorderSide(color: C.teal, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: C.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: C.teal, width: 1.6),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: C.line),
      ),
    ),
  );
}

String money(num v, [String cur = 'RWF']) {
  final s = v.round().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '$cur ${b.toString()}';
}

// ============================================================================
// 3. MODELS
// ============================================================================
class Property {
  final String id;
  final String ownerId;
  final String ownerName;
  final bool ownerVerified;
  final String title;
  final String description;
  final String type;          // apartment/house/studio/room/commercial
  final String status;        // draft/pending/active/rented/rejected
  final int bedrooms;
  final int bathrooms;
  final num price;
  final String currency;
  final bool furnished;
  final List<String> amenities;
  final String city;
  final String district;
  final String sector;
  final List<String> photos;
  final bool featured;

  Property({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerVerified,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.bedrooms,
    required this.bathrooms,
    required this.price,
    required this.currency,
    required this.furnished,
    required this.amenities,
    required this.city,
    required this.district,
    required this.sector,
    required this.photos,
    required this.featured,
  });

  String get location =>
      [sector, district, city].where((e) => e.trim().isNotEmpty).join(', ');

  factory Property.fromMap(Map<String, dynamic> m) {
    final owner = (m['owner'] as Map?) ?? const {};
    final photoRows = (m['property_photos'] as List?) ?? const [];
    return Property(
      id: m['id'].toString(),
      ownerId: (m['owner_id'] ?? '').toString(),
      ownerName: (owner['full_name'] ?? 'Owner').toString(),
      ownerVerified: owner['is_verified'] == true,
      title: (m['title'] ?? '').toString(),
      description: (m['description'] ?? '').toString(),
      type: (m['type'] ?? 'apartment').toString(),
      status: (m['status'] ?? 'active').toString(),
      bedrooms: (m['bedrooms'] ?? 1) as int,
      bathrooms: (m['bathrooms'] ?? 1) as int,
      price: (m['price_monthly'] ?? 0) as num,
      currency: (m['currency'] ?? 'RWF').toString(),
      furnished: m['is_furnished'] == true,
      amenities: ((m['amenities'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      city: (m['city'] ?? '').toString(),
      district: (m['district'] ?? '').toString(),
      sector: (m['sector'] ?? '').toString(),
      photos: photoRows.map((p) => (p['url'] ?? '').toString()).toList(),
      featured: m['is_featured'] == true,
    );
  }
}

// ============================================================================
// 4. SAMPLE DATA  — makes every screen real-looking before Supabase is wired.
// ============================================================================
class SampleData {
  static const _u = 'https://images.unsplash.com/';
  static List<Property> properties = [
    Property(
      id: 's1', ownerId: 'o1', ownerName: 'Aline M.', ownerVerified: true,
      title: 'Sunlit 2-bedroom in Kacyiru',
      description:
          'Bright, airy apartment steps from the ministries. Large balcony, '
          'backup water tank, and a quiet compound. Rent directly from the '
          'owner — no agent fees.',
      type: 'apartment', status: 'active', bedrooms: 2, bathrooms: 1,
      price: 320000, currency: 'RWF', furnished: true,
      amenities: ['Parking', 'Water tank', 'Balcony', 'Wi-Fi ready'],
      city: 'Kigali', district: 'Gasabo', sector: 'Kacyiru',
      featured: true,
      photos: [
        '${_u}photo-1502672260266-1c1ef2d93688?w=900',
        '${_u}photo-1522708323590-d24dbb6b0267?w=900',
        '${_u}photo-1560448204-e02f11c3d0e2?w=900',
      ],
    ),
    Property(
      id: 's2', ownerId: 'o2', ownerName: 'Jean-Paul H.', ownerVerified: false,
      title: 'Cozy studio near Kimironko market',
      description:
          'Perfect first place. Walkable to the market and buses. Freshly '
          'painted with tiled floors and a private entrance.',
      type: 'studio', status: 'active', bedrooms: 1, bathrooms: 1,
      price: 120000, currency: 'RWF', furnished: false,
      amenities: ['Private entrance', 'Tiled floors', 'Near transport'],
      city: 'Kigali', district: 'Gasabo', sector: 'Kimironko',
      featured: false,
      photos: [
        '${_u}photo-1493809842364-78817add7ffb?w=900',
        '${_u}photo-1505691938895-1758d7feb511?w=900',
      ],
    ),
    Property(
      id: 's3', ownerId: 'o3', ownerName: 'Claire U.', ownerVerified: true,
      title: 'Family house with garden — Nyarutarama',
      description:
          'Spacious 4-bedroom standalone house with a mature garden, staff '
          'quarter, and covered parking for two cars. Serene neighbourhood.',
      type: 'house', status: 'active', bedrooms: 4, bathrooms: 3,
      price: 1200000, currency: 'RWF', furnished: false,
      amenities: ['Garden', 'Parking x2', 'Staff quarter', 'Security'],
      city: 'Kigali', district: 'Gasabo', sector: 'Nyarutarama',
      featured: true,
      photos: [
        '${_u}photo-1568605114967-8130f3a36994?w=900',
        '${_u}photo-1449844908441-8829872d2607?w=900',
        '${_u}photo-1512917774080-9991f1c4c750?w=900',
      ],
    ),
    Property(
      id: 's4', ownerId: 'o1', ownerName: 'Aline M.', ownerVerified: true,
      title: 'Modern 3-bedroom — Kibagabaga',
      description:
          'Newly finished apartment with an open-plan kitchen, ensuite master '
          'bedroom, and a shared rooftop. Great light all day.',
      type: 'apartment', status: 'active', bedrooms: 3, bathrooms: 2,
      price: 550000, currency: 'RWF', furnished: true,
      amenities: ['Rooftop', 'Ensuite', 'Open kitchen', 'Elevator'],
      city: 'Kigali', district: 'Gasabo', sector: 'Kibagabaga',
      featured: false,
      photos: [
        '${_u}photo-1560185007-cde436f6a4d0?w=900',
        '${_u}photo-1522708323590-d24dbb6b0267?w=900',
      ],
    ),
  ];
}

// ============================================================================
// 5. SESSION  — light global state (role, profile, in-memory favorites).
// ============================================================================
class Session {
  static String role = 'tenant';      // 'tenant' | 'owner'
  static String name = 'Guest';
  static bool isDemo = true;          // true when no Supabase / demo login
  static final Set<String> favorites = {};

  static bool get isOwner => role == 'owner';
}

// ============================================================================
// 6. SERVICES
// ============================================================================
class AuthService {
  /// Real sign up. Returns null on success, or an error message.
  static Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
  }) async {
    if (sb == null) {
      // Demo fallback — no backend yet.
      Session
        ..role = role
        ..name = fullName.isEmpty ? 'You' : fullName
        ..isDemo = true;
      return null;
    }
    try {
      final res = await sb!.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'phone': phone, 'role': role},
        // ===== SPOT: SMS OTP =====
        // Phone/SMS OTP verification (Africa's Talking or Supabase phone auth)
        // gets wired here later. For now we use email/password.
        // =========================
      );
      if (res.user == null) return 'Could not create the account.';
      Session
        ..role = role
        ..name = fullName
        ..isDemo = false;
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  static Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    if (sb == null) {
      Session.isDemo = true;
      return null;
    }
    try {
      final res =
          await sb!.auth.signInWithPassword(email: email, password: password);
      if (res.user == null) return 'Invalid email or password.';
      await _loadProfile(res.user!.id);
      Session.isDemo = false;
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  static Future<void> _loadProfile(String uid) async {
    if (sb == null) return;
    try {
      final row = await sb!
          .from('profiles')
          .select('full_name, role')
          .eq('id', uid)
          .maybeSingle();
      if (row != null) {
        Session.name = (row['full_name'] ?? 'You').toString();
        Session.role = (row['role'] ?? 'tenant').toString();
      }
    } catch (_) {}
  }

  static Future<void> restoreSession() async {
    if (sb == null) return;
    final user = sb!.auth.currentUser;
    if (user != null) await _loadProfile(user.id);
  }

  static bool get isLoggedIn => sb != null && sb!.auth.currentUser != null;

  static Future<void> signOut() async {
    if (sb != null) await sb!.auth.signOut();
    Session
      ..role = 'tenant'
      ..name = 'Guest'
      ..isDemo = true
      ..favorites.clear();
  }
}

class DataService {
  /// Active listings for the tenant feed. Falls back to sample data.
  static Future<List<Property>> activeListings() async {
    if (sb == null) return SampleData.properties;
    try {
      final rows = await sb!
          .from('properties')
          .select(
              '*, owner:profiles!properties_owner_id_fkey(full_name,is_verified), property_photos(url,sort_order)')
          .eq('status', 'active')
          .order('is_featured', ascending: false)
          .order('created_at', ascending: false);
      final list = (rows as List)
          .map((e) => Property.fromMap(e as Map<String, dynamic>))
          .toList();
      return list.isEmpty ? SampleData.properties : list;
    } catch (_) {
      return SampleData.properties;
    }
  }

  /// The signed-in owner's own listings (any status).
  static Future<List<Property>> myListings() async {
    if (sb == null) {
      return SampleData.properties.where((p) => p.ownerId == 'o1').toList();
    }
    final uid = sb!.auth.currentUser?.id;
    if (uid == null) return [];
    try {
      final rows = await sb!
          .from('properties')
          .select(
              '*, owner:profiles!properties_owner_id_fkey(full_name,is_verified), property_photos(url,sort_order)')
          .eq('owner_id', uid)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((e) => Property.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Create or send an inquiry (opens a chat thread with the owner).
  static Future<String?> sendInquiry(Property p) async {
    if (sb == null) return null; // demo: pretend success
    final uid = sb!.auth.currentUser?.id;
    if (uid == null) return 'Please sign in first.';
    try {
      await sb!.from('inquiries').upsert({
        'property_id': p.id,
        'tenant_id': uid,
        'owner_id': p.ownerId,
        'status': 'new',
      }, onConflict: 'property_id,tenant_id');
      return null;
    } catch (e) {
      return 'Could not send your message.';
    }
  }

  /// Book a viewing.
  static Future<String?> bookViewing(Property p, DateTime when) async {
    if (sb == null) return null;
    final uid = sb!.auth.currentUser?.id;
    if (uid == null) return 'Please sign in first.';
    try {
      await sb!.from('viewings').insert({
        'property_id': p.id,
        'tenant_id': uid,
        'owner_id': p.ownerId,
        'requested_date': when.toIso8601String(),
        'status': 'requested',
      });
      return null;
    } catch (e) {
      return 'Could not request the viewing.';
    }
  }

  /// Create a new listing (owner). Returns null on success.
  static Future<String?> createListing({
    required String title,
    required String description,
    required String type,
    required int bedrooms,
    required int bathrooms,
    required num price,
    required bool furnished,
    required String city,
    required String district,
    required String sector,
  }) async {
    if (sb == null) return null; // demo
    final uid = sb!.auth.currentUser?.id;
    if (uid == null) return 'Please sign in first.';
    try {
      await sb!.from('properties').insert({
        'owner_id': uid,
        'title': title,
        'description': description,
        'type': type,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'price_monthly': price,
        'is_furnished': furnished,
        'city': city,
        'district': district,
        'sector': sector,
        'status': 'pending', // waits for admin approval in the portal
        // ===== SPOT: photo upload =====
        // After inserting, upload images to the 'property-photos' bucket and
        // insert their public URLs into property_photos. Enable image_picker
        // (add it to pubspec) and call sb.storage.from('property-photos')
        // .upload(...) then .getPublicUrl(...).
        // ==============================
      });
      return null;
    } catch (e) {
      return 'Could not save the listing.';
    }
  }
}

// ============================================================================
// 7. APP ROOT
// ============================================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AppConfig.isConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }
  runApp(const HomeDirectApp());
}

class HomeDirectApp extends StatelessWidget {
  const HomeDirectApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeDirect',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const SplashScreen(),
    );
  }
}

// ============================================================================
// 8. SPLASH  — animated brand entrance.
// ============================================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _logo;
  late final Animation<double> _text;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1700));
    _logo = CurvedAnimation(
        parent: _c, curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack));
    _text = CurvedAnimation(
        parent: _c, curve: const Interval(0.45, 1.0, curve: Curves.easeOut));
    _c.forward();
    _boot();
  }

  Future<void> _boot() async {
    await AuthService.restoreSession();
    await Future.delayed(const Duration(milliseconds: 2100));
    if (!mounted) return;
    if (AuthService.isLoggedIn) {
      _go(const RootShell());
    } else {
      _go(const WelcomeScreen());
    }
  }

  void _go(Widget w) {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: w),
    ));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: C.brandGradient),
        child: Stack(
          children: [
            // ambient floating shapes
            _blob(-60, -40, 220, C.tealLight.withOpacity(.35)),
            _blob(260, 520, 300, C.tealDeep.withOpacity(.5)),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _logo,
                    child: FadeTransition(
                      opacity: _logo,
                      child: const BrandMark(size: 96),
                    ),
                  ),
                  const SizedBox(height: 26),
                  FadeTransition(
                    opacity: _text,
                    child: Column(
                      children: const [
                        Text('HomeDirect',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5)),
                        SizedBox(height: 8),
                        Text('Rent straight from the owner',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 46,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _text,
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.2, color: Colors.white54),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double top, double left, double size, Color color) => Positioned(
        top: top,
        left: left,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      );
}

/// A little house + key mark, drawn (no image asset needed).
class BrandMark extends StatelessWidget {
  final double size;
  final Color? bg;
  const BrandMark({super.key, this.size = 72, this.bg});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg ?? Colors.white,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.15),
              blurRadius: 24,
              offset: const Offset(0, 10)),
        ],
      ),
      child: CustomPaint(painter: _HousePainter(), child: const SizedBox()),
    );
  }
}

class _HousePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = C.teal
      ..style = PaintingStyle.fill;
    final w = s.width, h = s.height;
    // roof
    final roof = Path()
      ..moveTo(w * .5, h * .24)
      ..lineTo(w * .78, h * .46)
      ..lineTo(w * .22, h * .46)
      ..close();
    canvas.drawPath(roof, p);
    // body
    final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .3, h * .46, w * .4, h * .3),
        Radius.circular(w * .04));
    canvas.drawRRect(body, p);
    // door (gold)
    final door = Paint()..color = C.gold;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * .45, h * .56, w * .1, h * .2),
          Radius.circular(w * .02)),
      door,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 9. WELCOME / ONBOARDING  — gradient hero + swipeable value slides.
// ============================================================================
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pc = PageController();
  int _i = 0;

  final _slides = const [
    _Slide(
      icon: Icons.handshake_outlined,
      title: 'No brokers.\nNo hidden fees.',
      body:
          'Talk to property owners directly and keep the extra month of rent an agent would have taken.',
    ),
    _Slide(
      icon: Icons.verified_user_outlined,
      title: 'Trust you\ncan see.',
      body:
          'Verified owners, real photos, and honest prices. Know who you are renting from before you visit.',
    ),
    _Slide(
      icon: Icons.tune_rounded,
      title: 'Find the\nright fit.',
      body:
          'Filter by neighbourhood, budget, and bedrooms. Save favourites and book a viewing in a tap.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: C.brandGradient),
        child: SafeArea(
          child: Column(
            children: [
              // top bar with brand + skip
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                child: Row(
                  children: [
                    const BrandMark(size: 38),
                    const SizedBox(width: 10),
                    const Text('HomeDirect',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18)),
                    const Spacer(),
                    TextButton(
                      onPressed: _openAuth,
                      child: const Text('Skip',
                          style: TextStyle(color: Colors.white70)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pc,
                  itemCount: _slides.length,
                  onPageChanged: (v) => setState(() => _i = v),
                  itemBuilder: (_, i) => _slides[i],
                ),
              ),
              // dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final on = i == _i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: on ? 26 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: on ? C.gold : Colors.white38,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: C.gold,
                          foregroundColor: C.ink,
                        ),
                        onPressed: () {
                          if (_i < _slides.length - 1) {
                            _pc.nextPage(
                                duration: const Duration(milliseconds: 320),
                                curve: Curves.easeOut);
                          } else {
                            _openAuth();
                          }
                        },
                        child: Text(_i < _slides.length - 1
                            ? 'Next'
                            : 'Get started'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _openAuth,
                      child: const Text('I already have an account',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAuth() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AuthScreen()));
  }
}

class _Slide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _Slide({required this.icon, required this.title, required this.body});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.14),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: C.gold, size: 40),
          ),
          const SizedBox(height: 28),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8)),
          const SizedBox(height: 16),
          Text(body,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 16, height: 1.5)),
        ],
      ),
    );
  }
}

// ============================================================================
// 10. AUTH  — login / signup toggle + role picker, wired to Supabase.
// ============================================================================
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _busy = false;
  String _role = 'tenant';
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isLogin ? 'Welcome back' : 'Create your account',
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: C.ink,
                      letterSpacing: -0.6)),
              const SizedBox(height: 6),
              Text(
                  _isLogin
                      ? 'Sign in to pick up where you left off.'
                      : 'A minute to set up. Choose how you want to use HomeDirect.',
                  style: const TextStyle(color: C.muted, fontSize: 15)),
              const SizedBox(height: 24),

              if (!_isLogin) ...[
                const _Label('I am a…'),
                Row(
                  children: [
                    _RoleChip(
                      label: 'Tenant',
                      sub: 'Looking to rent',
                      icon: Icons.search_rounded,
                      selected: _role == 'tenant',
                      onTap: () => setState(() => _role = 'tenant'),
                    ),
                    const SizedBox(width: 12),
                    _RoleChip(
                      label: 'Owner',
                      sub: 'Listing a place',
                      icon: Icons.home_work_outlined,
                      selected: _role == 'owner',
                      onTap: () => setState(() => _role = 'owner'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const _Label('Full name'),
                TextField(
                    controller: _name,
                    decoration:
                        const InputDecoration(hintText: 'e.g. Aline Mukamana')),
                const SizedBox(height: 14),
                const _Label('Phone'),
                TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration:
                        const InputDecoration(hintText: '+2507…')),
                const SizedBox(height: 14),
              ],

              const _Label('Email'),
              TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'you@email.com')),
              const SizedBox(height: 14),
              const _Label('Password'),
              TextField(
                  controller: _pass,
                  obscureText: true,
                  decoration:
                      const InputDecoration(hintText: 'At least 6 characters')),
              const SizedBox(height: 24),

              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.2, color: Colors.white))
                    : Text(_isLogin ? 'Sign in' : 'Create account'),
              ),
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin
                        ? "New here? Create an account"
                        : 'Already have an account? Sign in',
                    style: const TextStyle(
                        color: C.teal, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (!AppConfig.isConfigured)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: C.gold.withOpacity(.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: C.gold.withOpacity(.5)),
                  ),
                  child: const Text(
                    'Demo mode: Supabase keys not set yet, so any details will '
                    'sign you into a sample version with example listings.',
                    style: TextStyle(color: C.goldDeep, fontSize: 13),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    String? err;
    if (_isLogin) {
      err = await AuthService.signIn(
          email: _email.text.trim(), password: _pass.text);
    } else {
      err = await AuthService.signUp(
        email: _email.text.trim(),
        password: _pass.text,
        fullName: _name.text.trim(),
        phone: _phone.text.trim(),
        role: _role,
      );
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootShell()),
      (r) => false,
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label, sub;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _RoleChip(
      {required this.label,
      required this.sub,
      required this.icon,
      required this.selected,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? C.teal : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected ? C.teal : C.line, width: 1.4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon,
                  color: selected ? C.gold : C.teal, size: 26),
              const SizedBox(height: 10),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: selected ? Colors.white : C.ink)),
              Text(sub,
                  style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white70 : C.muted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: C.ink, fontSize: 14)),
      );
}

// ============================================================================
// 11. ROOT SHELL  — bottom nav differs by role.
// ============================================================================
class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final tenantTabs = [
      const HomeFeedScreen(),
      const FavoritesScreen(),
      const InboxScreen(),
      const ProfileScreen(),
    ];
    final ownerTabs = [
      const OwnerDashboardScreen(),
      const InboxScreen(),
      const ProfileScreen(),
    ];
    final tabs = Session.isOwner ? ownerTabs : tenantTabs;
    final items = Session.isOwner
        ? const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Listings'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Inbox'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile'),
          ]
        : const [
            BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'Explore'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                activeIcon: Icon(Icons.favorite),
                label: 'Saved'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Inbox'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile'),
          ];
    if (_i >= tabs.length) _i = 0;
    return Scaffold(
      body: IndexedStack(index: _i, children: tabs),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: C.line)),
        ),
        child: BottomNavigationBar(
          currentIndex: _i,
          onTap: (v) => setState(() => _i = v),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: C.teal,
          unselectedItemColor: C.muted,
          showUnselectedLabels: true,
          elevation: 0,
          items: items,
        ),
      ),
      floatingActionButton: Session.isOwner
          ? FloatingActionButton.extended(
              backgroundColor: C.teal,
              foregroundColor: Colors.white,
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ListingEditorScreen())),
              icon: const Icon(Icons.add),
              label: const Text('New listing'),
            )
          : null,
    );
  }
}

// ============================================================================
// 12. TENANT — HOME FEED (search + filters + rich cards)
// ============================================================================
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});
  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  late Future<List<Property>> _future;
  String _query = '';
  String _type = 'all';
  int _minBeds = 0;
  num _maxPrice = 0; // 0 = no cap

  @override
  void initState() {
    super.initState();
    _future = DataService.activeListings();
  }

  List<Property> _apply(List<Property> all) {
    return all.where((p) {
      if (_type != 'all' && p.type != _type) return false;
      if (_minBeds > 0 && p.bedrooms < _minBeds) return false;
      if (_maxPrice > 0 && p.price > _maxPrice) return false;
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        if (!p.title.toLowerCase().contains(q) &&
            !p.location.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: FutureBuilder<List<Property>>(
          future: _future,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = snap.data!;
            final list = _apply(all);
            final featured = all.where((p) => p.featured).toList();
            return RefreshIndicator(
              onRefresh: () async {
                setState(() => _future = DataService.activeListings());
                await _future;
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _header()),
                  if (_query.isEmpty && featured.isNotEmpty)
                    SliverToBoxAdapter(child: _featuredRail(featured)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Row(
                        children: [
                          Text('${list.length} places',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: C.ink)),
                          const Spacer(),
                          const Text('Direct from owners',
                              style:
                                  TextStyle(color: C.muted, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  if (list.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: Text('No places match your filters yet.',
                              style: TextStyle(color: C.muted)),
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => PropertyCard(
                          property: list[i],
                          onTap: () => _open(list[i]),
                        ),
                        childCount: list.length,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hi ${Session.name.split(' ').first} 👋',
                      style: const TextStyle(
                          color: C.muted, fontWeight: FontWeight.w600)),
                  const Text('Find your next home',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: C.ink,
                          letterSpacing: -0.6)),
                ],
              ),
              const Spacer(),
              const BrandMark(size: 42, bg: C.teal),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search neighbourhood or title',
                    prefixIcon: const Icon(Icons.search, color: C.muted),
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: C.teal,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _openFilters,
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Icon(Icons.tune_rounded, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final t in const [
                  ['all', 'All'],
                  ['apartment', 'Apartments'],
                  ['house', 'Houses'],
                  ['studio', 'Studios'],
                  ['room', 'Rooms'],
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(t[1]),
                      selected: _type == t[0],
                      onSelected: (_) => setState(() => _type = t[0]),
                      selectedColor: C.teal,
                      labelStyle: TextStyle(
                          color: _type == t[0] ? Colors.white : C.ink,
                          fontWeight: FontWeight.w600),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: C.line),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuredRail(List<Property> featured) {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 6, 8, 10),
        itemCount: featured.length,
        itemBuilder: (_, i) {
          final p = featured[i];
          return GestureDetector(
            onTap: () => _open(p),
            child: Container(
              width: 260,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                      p.photos.isNotEmpty ? p.photos.first : ''),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(.75)
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: C.gold,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text('Featured',
                          style: TextStyle(
                              color: C.ink,
                              fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(height: 8),
                    Text(p.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                    Text(money(p.price, p.currency) + ' / mo',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _open(Property p) => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: p)));

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx, setSheet) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: SizedBox(
                    width: 44,
                    child: Divider(thickness: 4, color: C.line)),
              ),
              const SizedBox(height: 12),
              const Text('Filters',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800, color: C.ink)),
              const SizedBox(height: 20),
              const _Label('Minimum bedrooms'),
              Wrap(
                spacing: 8,
                children: [0, 1, 2, 3, 4].map((n) {
                  final on = _minBeds == n;
                  return ChoiceChip(
                    label: Text(n == 0 ? 'Any' : '$n+'),
                    selected: on,
                    onSelected: (_) => setSheet(() => _minBeds = n),
                    selectedColor: C.teal,
                    labelStyle: TextStyle(
                        color: on ? Colors.white : C.ink,
                        fontWeight: FontWeight.w600),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: C.line),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              const _Label('Max budget / month'),
              Wrap(
                spacing: 8,
                children: [0, 150000, 300000, 600000, 1000000].map((v) {
                  final on = _maxPrice == v;
                  return ChoiceChip(
                    label: Text(v == 0 ? 'Any' : money(v)),
                    selected: on,
                    onSelected: (_) => setSheet(() => _maxPrice = v),
                    selectedColor: C.teal,
                    labelStyle: TextStyle(
                        color: on ? Colors.white : C.ink,
                        fontWeight: FontWeight.w600),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: C.line),
                  );
                }).toList(),
              ),
              const SizedBox(height: 26),
              FilledButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(ctx);
                },
                child: const Text('Show results'),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ============================================================================
// 13. PROPERTY CARD (shared)
// ============================================================================
class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  const PropertyCard({super.key, required this.property, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = property;
    final saved = Session.favorites.contains(p.id);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: C.line),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.04),
                blurRadius: 18,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: p.photos.isNotEmpty
                        ? Image.network(p.photos.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imgFallback(),
                            loadingBuilder: (c, w, prog) => prog == null
                                ? w
                                : Container(color: C.line))
                        : _imgFallback(),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.9),
                        shape: BoxShape.circle),
                    child: Icon(
                        saved ? Icons.favorite : Icons.favorite_border,
                        color: saved ? C.danger : C.ink,
                        size: 20),
                  ),
                ),
                if (p.furnished)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _pill('Furnished', C.teal),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(p.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: C.ink)),
                      ),
                      if (p.ownerVerified)
                        const Icon(Icons.verified,
                            color: C.teal, size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined,
                          size: 15, color: C.muted),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(p.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: C.muted, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _spec(Icons.king_bed_outlined, '${p.bedrooms} bd'),
                      const SizedBox(width: 14),
                      _spec(Icons.bathtub_outlined, '${p.bathrooms} ba'),
                      const SizedBox(width: 14),
                      _spec(Icons.home_outlined, _typeLabel(p.type)),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(money(p.price, p.currency),
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: C.teal)),
                      const Text(' / month',
                          style: TextStyle(color: C.muted, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgFallback() => Container(
        color: C.line,
        child: const Center(
            child: Icon(Icons.image_outlined, color: C.muted, size: 40)),
      );

  static Widget _pill(String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration:
            BoxDecoration(color: c, borderRadius: BorderRadius.circular(8)),
        child: Text(t,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      );

  static Widget _spec(IconData i, String t) => Row(
        children: [
          Icon(i, size: 16, color: C.muted),
          const SizedBox(width: 4),
          Text(t, style: const TextStyle(color: C.ink, fontSize: 13)),
        ],
      );
}

String _typeLabel(String t) {
  switch (t) {
    case 'apartment':
      return 'Apartment';
    case 'house':
      return 'House';
    case 'studio':
      return 'Studio';
    case 'room':
      return 'Room';
    case 'commercial':
      return 'Commercial';
    default:
      return t;
  }
}

// ============================================================================
// 14. PROPERTY DETAIL
// ============================================================================
class PropertyDetailScreen extends StatefulWidget {
  final Property property;
  const PropertyDetailScreen({super.key, required this.property});
  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final _page = PageController();
  int _photo = 0;

  Property get p => widget.property;

  @override
  Widget build(BuildContext context) {
    final saved = Session.favorites.contains(p.id);
    return Scaffold(
      backgroundColor: C.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: C.teal,
            leading: _circleBtn(Icons.arrow_back, () => Navigator.pop(context)),
            actions: [
              _circleBtn(saved ? Icons.favorite : Icons.favorite_border, () {
                setState(() {
                  saved
                      ? Session.favorites.remove(p.id)
                      : Session.favorites.add(p.id);
                });
              }, color: saved ? C.danger : C.ink),
              _circleBtn(Icons.share_outlined, () {
                // ===== SPOT: share sheet (share_plus) =====
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Sharing comes soon.')));
              }),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _page,
                    onPageChanged: (v) => setState(() => _photo = v),
                    itemCount: p.photos.isEmpty ? 1 : p.photos.length,
                    itemBuilder: (_, i) => p.photos.isEmpty
                        ? Container(color: C.line)
                        : Image.network(p.photos[i],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: C.line)),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          p.photos.isEmpty ? 1 : p.photos.length, (i) {
                        final on = i == _photo;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: on ? 20 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                              color: on ? Colors.white : Colors.white54,
                              borderRadius: BorderRadius.circular(6)),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -18, 0),
              decoration: const BoxDecoration(
                color: C.bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: C.teal.withOpacity(.1),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(_typeLabel(p.type),
                            style: const TextStyle(
                                color: C.teal,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                      ),
                      const Spacer(),
                      Text(money(p.price, p.currency),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: C.teal)),
                      const Text(' /mo',
                          style: TextStyle(color: C.muted)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(p.title,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: C.ink,
                          height: 1.2)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined,
                          size: 17, color: C.muted),
                      const SizedBox(width: 4),
                      Text(p.location,
                          style: const TextStyle(color: C.muted)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _statBox(Icons.king_bed_outlined, '${p.bedrooms}',
                          'Bedrooms'),
                      const SizedBox(width: 12),
                      _statBox(Icons.bathtub_outlined, '${p.bathrooms}',
                          'Bathrooms'),
                      const SizedBox(width: 12),
                      _statBox(Icons.weekend_outlined,
                          p.furnished ? 'Yes' : 'No', 'Furnished'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('About this place'),
                  Text(p.description,
                      style: const TextStyle(
                          color: C.ink, height: 1.6, fontSize: 15)),
                  const SizedBox(height: 24),
                  if (p.amenities.isNotEmpty) ...[
                    const _SectionTitle('What this place offers'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: p.amenities
                          .map((a) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: C.line)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle_outline,
                                        size: 16, color: C.teal),
                                    const SizedBox(width: 6),
                                    Text(a,
                                        style:
                                            const TextStyle(color: C.ink)),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const _SectionTitle('Location'),
                  // ===== SPOT: Google Maps =====
                  // Replace this placeholder with a GoogleMap widget centred on
                  // p.latitude / p.longitude once the Maps API key is added.
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: C.teal.withOpacity(.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: C.line),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_outlined, color: C.teal, size: 34),
                          SizedBox(height: 8),
                          Text('Map coming soon',
                              style: TextStyle(color: C.muted)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('Listed by'),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: C.teal,
                        child: Text(
                            p.ownerName.isNotEmpty
                                ? p.ownerName[0].toUpperCase()
                                : 'O',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(p.ownerName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: C.ink,
                                      fontSize: 15)),
                              const SizedBox(width: 6),
                              if (p.ownerVerified)
                                const Icon(Icons.verified,
                                    color: C.teal, size: 16),
                            ],
                          ),
                          Text(
                              p.ownerVerified
                                  ? 'Identity verified'
                                  : 'Owner',
                              style: const TextStyle(
                                  color: C.muted, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Session.isOwner
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: C.line)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _bookViewing,
                        icon: const Icon(Icons.event_available_outlined),
                        label: const Text('Book viewing'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _contact,
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Contact'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _circleBtn(IconData i, VoidCallback onTap, {Color color = C.ink}) =>
      Padding(
        padding: const EdgeInsets.all(8),
        child: Material(
          color: Colors.white.withOpacity(.9),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(i, color: color, size: 20),
            ),
          ),
        ),
      );

  Widget _statBox(IconData i, String v, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: C.line)),
          child: Column(
            children: [
              Icon(i, color: C.teal, size: 22),
              const SizedBox(height: 6),
              Text(v,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: C.ink)),
              Text(label,
                  style: const TextStyle(color: C.muted, fontSize: 12)),
            ],
          ),
        ),
      );

  Future<void> _contact() async {
    final err = await DataService.sendInquiry(p);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChatScreen(
            title: p.ownerName, subtitle: p.title, property: p)));
  }

  Future<void> _bookViewing() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      initialDate: now.add(const Duration(days: 1)),
    );
    if (date == null) return;
    final err = await DataService.bookViewing(p, date);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err ??
            'Viewing requested for ${date.day}/${date.month}. The owner will confirm.')));
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: C.ink)),
      );
}

// ============================================================================
// 15. FAVORITES
// ============================================================================
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final saved = SampleData.properties
        .where((p) => Session.favorites.contains(p.id))
        .toList();
    // NOTE: with Supabase wired, load from the `favorites` table joined to
    // properties instead of filtering the in-memory sample list.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: saved.isEmpty
          ? const _Empty(
              icon: Icons.favorite_border,
              title: 'No saved places yet',
              body: 'Tap the heart on a listing to keep it here.')
          : ListView(
              padding: const EdgeInsets.all(16),
              children: saved
                  .map((p) => PropertyCard(
                        property: p,
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    PropertyDetailScreen(property: p))),
                      ))
                  .toList(),
            ),
    );
  }
}

// ============================================================================
// 16. INBOX + CHAT
// ============================================================================
class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // Demo threads from sample listings.
    final threads = SampleData.properties.take(2).toList();
    return Scaffold(
      appBar: AppBar(
          title: const Text('Inbox',
              style: TextStyle(fontWeight: FontWeight.w800))),
      body: threads.isEmpty
          ? const _Empty(
              icon: Icons.chat_bubble_outline,
              title: 'No conversations yet',
              body: 'When you contact an owner, your chats appear here.')
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: threads.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: C.line),
              itemBuilder: (_, i) {
                final p = threads[i];
                final who = Session.isOwner ? 'A tenant' : p.ownerName;
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: C.teal,
                    child: Text(who[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800)),
                  ),
                  title: Text(who,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(p.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Text('now',
                      style: TextStyle(color: C.muted, fontSize: 12)),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChatScreen(
                          title: who, subtitle: p.title, property: p))),
                );
              },
            ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String title, subtitle;
  final Property property;
  const ChatScreen(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.property});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _messages = <_Msg>[
    _Msg('Hi! Is this place still available?', true),
    _Msg('Yes, it is. Would you like to book a viewing?', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16)),
            Text(widget.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: C.muted, fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[_messages.length - 1 - i];
                return Align(
                  alignment:
                      m.mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(context).size.width * 0.72),
                    decoration: BoxDecoration(
                      color: m.mine ? C.teal : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(m.mine ? 16 : 4),
                        bottomRight: Radius.circular(m.mine ? 4 : 16),
                      ),
                      border: m.mine ? null : Border.all(color: C.line),
                    ),
                    child: Text(m.text,
                        style: TextStyle(
                            color: m.mine ? Colors.white : C.ink,
                            height: 1.3)),
                  ),
                );
              },
            ),
          ),
          // ===== SPOT: realtime chat =====
          // Wire this to the `messages` table with Supabase Realtime so the two
          // parties see live updates. For now messages are local-only.
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: C.line)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: C.muted),
                    onPressed: () {
                      // ===== SPOT: chat-attachments upload =====
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Attachments come soon.')));
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: InputDecoration(
                        hintText: 'Message…',
                        filled: true,
                        fillColor: C.bg,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Material(
                    color: C.teal,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _send,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _messages.add(_Msg(t, true));
      _ctrl.clear();
    });
  }
}

class _Msg {
  final String text;
  final bool mine;
  _Msg(this.text, this.mine);
}

// ============================================================================
// 17. OWNER DASHBOARD
// ============================================================================
class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});
  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  late Future<List<Property>> _future;

  @override
  void initState() {
    super.initState();
    _future = DataService.myListings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: FutureBuilder<List<Property>>(
          future: _future,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final mine = snap.data!;
            final active = mine.where((p) => p.status == 'active').length;
            final pending = mine.where((p) => p.status == 'pending').length;
            return RefreshIndicator(
              onRefresh: () async {
                setState(() => _future = DataService.myListings());
                await _future;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your listings',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: C.ink,
                                  letterSpacing: -0.6)),
                          Text('Welcome, ${Session.name.split(' ').first}',
                              style: const TextStyle(color: C.muted)),
                        ],
                      ),
                      const Spacer(),
                      const BrandMark(size: 42, bg: C.teal),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _metric('${mine.length}', 'Total'),
                      const SizedBox(width: 12),
                      _metric('$active', 'Active'),
                      const SizedBox(width: 12),
                      _metric('$pending', 'In review'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (mine.isEmpty)
                    const _Empty(
                      icon: Icons.home_work_outlined,
                      title: 'No listings yet',
                      body: 'Tap “New listing” to publish your first place.',
                    )
                  else
                    ...mine.map((p) => _ownerCard(p)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _metric(String v, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: C.line),
          ),
          child: Column(
            children: [
              Text(v,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: C.teal)),
              Text(label,
                  style: const TextStyle(color: C.muted, fontSize: 13)),
            ],
          ),
        ),
      );

  Widget _ownerCard(Property p) {
    Color statusColor;
    switch (p.status) {
      case 'active':
        statusColor = C.teal;
        break;
      case 'pending':
        statusColor = C.goldDeep;
        break;
      case 'rejected':
        statusColor = C.danger;
        break;
      default:
        statusColor = C.muted;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.line),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(16)),
            child: SizedBox(
              width: 110,
              height: 110,
              child: p.photos.isNotEmpty
                  ? Image.network(p.photos.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: C.line))
                  : Container(color: C.line),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, color: C.ink)),
                  const SizedBox(height: 2),
                  Text(money(p.price, p.currency) + ' /mo',
                      style: const TextStyle(color: C.teal)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: statusColor.withOpacity(.12),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(_statusLabel(p.status),
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                      const Spacer(),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.edit_outlined,
                            size: 20, color: C.muted),
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    ListingEditorScreen(existing: p))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(String s) {
  switch (s) {
    case 'active':
      return 'Live';
    case 'pending':
      return 'In review';
    case 'rejected':
      return 'Rejected';
    case 'rented':
      return 'Rented';
    case 'draft':
      return 'Draft';
    default:
      return s;
  }
}

// ============================================================================
// 18. LISTING EDITOR (create / edit)
// ============================================================================
class ListingEditorScreen extends StatefulWidget {
  final Property? existing;
  const ListingEditorScreen({super.key, this.existing});
  @override
  State<ListingEditorScreen> createState() => _ListingEditorScreenState();
}

class _ListingEditorScreenState extends State<ListingEditorScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _city = TextEditingController(text: 'Kigali');
  final _district = TextEditingController();
  final _sector = TextEditingController();
  String _type = 'apartment';
  int _beds = 1;
  int _baths = 1;
  bool _furnished = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _title.text = e.title;
      _desc.text = e.description;
      _price.text = e.price.round().toString();
      _city.text = e.city;
      _district.text = e.district;
      _sector.text = e.sector;
      _type = e.type;
      _beds = e.bedrooms;
      _baths = e.bathrooms;
      _furnished = e.furnished;
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Edit listing' : 'New listing',
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== SPOT: photo upload =====
            GestureDetector(
              onTap: () {
                // Enable image_picker + storage upload here (see createListing).
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text('Photo upload is wired to the storage bucket next.')));
              },
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: C.teal.withOpacity(.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: C.teal.withOpacity(.4),
                      style: BorderStyle.solid,
                      width: 1.4),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined,
                          color: C.teal, size: 32),
                      SizedBox(height: 8),
                      Text('Add photos',
                          style: TextStyle(
                              color: C.teal, fontWeight: FontWeight.w700)),
                      Text('Bright, real photos get more replies',
                          style: TextStyle(color: C.muted, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const _Label('Title'),
            TextField(
                controller: _title,
                decoration: const InputDecoration(
                    hintText: 'e.g. Sunny 2-bedroom in Kacyiru')),
            const SizedBox(height: 14),
            const _Label('Description'),
            TextField(
                controller: _desc,
                maxLines: 4,
                decoration: const InputDecoration(
                    hintText: 'What makes this place great to live in?')),
            const SizedBox(height: 14),
            const _Label('Type'),
            Wrap(
              spacing: 8,
              children: ['apartment', 'house', 'studio', 'room', 'commercial']
                  .map((t) {
                final on = _type == t;
                return ChoiceChip(
                  label: Text(_typeLabel(t)),
                  selected: on,
                  onSelected: (_) => setState(() => _type = t),
                  selectedColor: C.teal,
                  labelStyle: TextStyle(
                      color: on ? Colors.white : C.ink,
                      fontWeight: FontWeight.w600),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: C.line),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _stepper('Bedrooms', _beds, (v) => setState(() => _beds = v))),
                const SizedBox(width: 12),
                Expanded(child: _stepper('Bathrooms', _baths, (v) => setState(() => _baths = v))),
              ],
            ),
            const SizedBox(height: 16),
            const _Label('Monthly rent (RWF)'),
            TextField(
                controller: _price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'e.g. 250000')),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('District'),
                      TextField(
                          controller: _district,
                          decoration:
                              const InputDecoration(hintText: 'Gasabo')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Sector'),
                      TextField(
                          controller: _sector,
                          decoration:
                              const InputDecoration(hintText: 'Kacyiru')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: C.teal,
              value: _furnished,
              onChanged: (v) => setState(() => _furnished = v),
              title: const Text('Furnished',
                  style: TextStyle(fontWeight: FontWeight.w700, color: C.ink)),
              subtitle: const Text('Comes with furniture'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: _busy
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: Colors.white))
                  : Text(editing ? 'Save changes' : 'Publish listing'),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text('New listings are reviewed before going live.',
                  style: TextStyle(color: C.muted, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepper(String label, int value, ValueChanged<int> onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: C.line),
          ),
          child: Row(
            children: [
              IconButton(
                  onPressed: value > 0 ? () => onChange(value - 1) : null,
                  icon: const Icon(Icons.remove)),
              Expanded(
                child: Text('$value',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
              ),
              IconButton(
                  onPressed: () => onChange(value + 1),
                  icon: const Icon(Icons.add)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _price.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please add at least a title and a price.')));
      return;
    }
    setState(() => _busy = true);
    final err = await DataService.createListing(
      title: _title.text.trim(),
      description: _desc.text.trim(),
      type: _type,
      bedrooms: _beds,
      bathrooms: _baths,
      price: num.tryParse(_price.text.trim()) ?? 0,
      furnished: _furnished,
      city: _city.text.trim(),
      district: _district.text.trim(),
      sector: _sector.text.trim(),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err ?? 'Listing saved. It will appear after review.')));
    if (err == null) Navigator.pop(context);
  }
}

// ============================================================================
// 19. PROFILE
// ============================================================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: C.teal,
                  child: Text(
                      Session.name.isNotEmpty
                          ? Session.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Session.name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: C.ink)),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: C.teal.withOpacity(.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                          Session.isOwner ? 'Property owner' : 'Tenant',
                          style: const TextStyle(
                              color: C.teal,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (Session.isOwner)
              _tile(Icons.verified_user_outlined, 'Verify your identity',
                  'Build trust with tenants', () {
                // ===== SPOT: verification-docs upload =====
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text('Upload your ID/title deed — coming next.')));
              }),
            _tile(Icons.event_available_outlined, 'My viewings',
                'Requests and confirmations', () {}),
            _tile(Icons.receipt_long_outlined, 'Payments',
                'Rent & deposits', () {
              // ===== SPOT: MoMo / aggregator payments =====
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('MoMo & card payments come soon.')));
            }),
            _tile(Icons.picture_as_pdf_outlined, 'Export a receipt',
                'Download as PDF', () {
              // ===== SPOT: PDF export =====
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('PDF export comes soon.')));
            }),
            _tile(Icons.settings_outlined, 'Settings', 'Notifications, language',
                () {}),
            _tile(Icons.help_outline, 'Help & safety',
                'How to rent safely', () {}),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: C.danger,
                side: const BorderSide(color: C.danger),
              ),
              onPressed: () async {
                await AuthService.signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (r) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                  AppConfig.isConfigured
                      ? 'HomeDirect • connected'
                      : 'HomeDirect • demo mode',
                  style: const TextStyle(color: C.muted, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
          IconData i, String title, String sub, VoidCallback onTap) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: C.line),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: C.teal.withOpacity(.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(i, color: C.teal),
          ),
          title: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: C.ink)),
          subtitle: Text(sub),
          trailing:
              const Icon(Icons.chevron_right, color: C.muted),
        ),
      );
}

// ============================================================================
// Shared empty-state widget
// ============================================================================
class _Empty extends StatelessWidget {
  final IconData icon;
  final String title, body;
  const _Empty(
      {required this.icon, required this.title, required this.body});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
                color: C.teal.withOpacity(.08),
                shape: BoxShape.circle),
            child: Icon(icon, color: C.teal, size: 38),
          ),
          const SizedBox(height: 18),
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: C.ink)),
          const SizedBox(height: 6),
          Text(body,
              textAlign: TextAlign.center,
              style: const TextStyle(color: C.muted, height: 1.4)),
        ],
      ),
    );
  }
}
