import 'package:flutter/material.dart';

void main() {
  runApp(const HomeDirectApp());
}

// ---------------------------------------------------------------------------
// APP ROOT + THEME
// One shared theme so every screen looks consistent. Change the `seed` color
// to re-skin the whole app.
// ---------------------------------------------------------------------------
class HomeDirectApp extends StatelessWidget {
  const HomeDirectApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0E7C66); // deep teal-green = "trust"

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seed),
      scaffoldBackgroundColor: const Color(0xFFF7F9F8),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDDE3E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDDE3E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: seed, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );

    return MaterialApp(
      title: 'HomeDirect',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const WelcomeScreen(),
    );
  }
}

// Two roles a user can sign up as.
enum UserRole { tenant, owner }

// ---------------------------------------------------------------------------
// 1. WELCOME
// ---------------------------------------------------------------------------
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.home_rounded,
                    color: Colors.white, size: 34),
              ),
              const SizedBox(height: 28),
              Text('HomeDirect',
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface)),
              const SizedBox(height: 12),
              Text(
                'Rent directly from owners.\nNo brokers. No hidden fees.',
                style: TextStyle(
                    fontSize: 17, height: 1.4, color: cs.onSurfaceVariant),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen())),
                child: const Text('Get started'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: const Text('I already have an account'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. LOG IN
// ---------------------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface)),
              const SizedBox(height: 8),
              Text('Log in to continue',
                  style:
                      TextStyle(color: cs.onSurfaceVariant, fontSize: 15)),
              const SizedBox(height: 28),
              const _FieldLabel('Email'),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    const InputDecoration(hintText: 'you@example.com'),
              ),
              const SizedBox(height: 18),
              const _FieldLabel('Password'),
              TextField(
                controller: _password,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      _showSnack(context, 'Password reset — coming soon'),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                // MOCK: no real auth yet — go straight to a placeholder home.
                onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const HomePlaceholder(role: 'Tenant'))),
                child: const Text('Log in'),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SignUpScreen())),
                  child: const Text("Don't have an account? Sign up"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. SIGN UP (with role selection)
// ---------------------------------------------------------------------------
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  UserRole? _role; // null until the user picks a card

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create your account',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface)),
              const SizedBox(height: 8),
              Text('First, tell us who you are',
                  style:
                      TextStyle(color: cs.onSurfaceVariant, fontSize: 15)),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _RoleCard(
                      icon: Icons.search_rounded,
                      title: "I'm looking\nfor a home",
                      selected: _role == UserRole.tenant,
                      onTap: () =>
                          setState(() => _role = UserRole.tenant),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RoleCard(
                      icon: Icons.vpn_key_rounded,
                      title: "I own\nproperty",
                      selected: _role == UserRole.owner,
                      onTap: () =>
                          setState(() => _role = UserRole.owner),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _FieldLabel('Full name'),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Jane Doe'),
              ),
              const SizedBox(height: 18),
              const _FieldLabel('Email'),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    const InputDecoration(hintText: 'you@example.com'),
              ),
              const SizedBox(height: 18),
              const _FieldLabel('Password'),
              TextField(
                controller: _password,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'At least 8 characters',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                // Disabled until a role is chosen.
                onPressed: _role == null
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PhoneVerificationScreen(role: _role!),
                          ),
                        ),
                child: const Text('Continue'),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen())),
                  child: const Text('Already have an account? Log in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. PHONE VERIFICATION (OTP)
// ---------------------------------------------------------------------------
class PhoneVerificationScreen extends StatelessWidget {
  final UserRole role;
  const PhoneVerificationScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Verify your phone',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface)),
              const SizedBox(height: 8),
              Text('We sent a 6-digit code to your number. Enter it below.',
                  style: TextStyle(
                      color: cs.onSurfaceVariant, fontSize: 15, height: 1.4)),
              const SizedBox(height: 32),
              TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 12,
                    fontWeight: FontWeight.w700),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '––––––',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            ProfileCompletionScreen(role: role))),
                child: const Text('Verify'),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => _showSnack(context, 'Code resent (mock)'),
                  child: const Text('Resend code'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. PROFILE COMPLETION
// ---------------------------------------------------------------------------
class ProfileCompletionScreen extends StatelessWidget {
  final UserRole role;
  const ProfileCompletionScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Complete your profile',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface)),
              const SizedBox(height: 8),
              Text(
                  'Add a photo and verify your ID to earn a trusted badge.',
                  style: TextStyle(
                      color: cs.onSurfaceVariant, fontSize: 15, height: 1.4)),
              const SizedBox(height: 28),
              Center(
                child: GestureDetector(
                  onTap: () =>
                      _showSnack(context, 'Photo picker — coming soon'),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: cs.primary.withOpacity(0.12),
                        child: Icon(Icons.person_rounded,
                            size: 48, color: cs.primary),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: cs.primary,
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const _FieldLabel('Phone number'),
              TextField(
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(hintText: '+250 7•• ••• •••'),
              ),
              const SizedBox(height: 18),
              const _FieldLabel('ID document (for verification badge)'),
              OutlinedButton.icon(
                onPressed: () =>
                    _showSnack(context, 'Document upload — coming soon'),
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Upload ID document'),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomePlaceholder(
                        role:
                            role == UserRole.owner ? 'Owner' : 'Tenant'),
                  ),
                  (route) => false,
                ),
                child: const Text('Finish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. HOME PLACEHOLDER
// Just closes the loop so the flow feels complete. The real tenant/owner
// home screens replace this in the next slice.
// ---------------------------------------------------------------------------
class HomePlaceholder extends StatelessWidget {
  final String role;
  const HomePlaceholder({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child:
                    Icon(Icons.check_rounded, size: 40, color: cs.primary),
              ),
              const SizedBox(height: 20),
              Text("You're in as a $role",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface)),
              const SizedBox(height: 10),
              Text(
                'Auth slice complete. Next up: the '
                '${role == 'Owner' ? 'listing management' : 'browse & search'} '
                'screens.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15, height: 1.4, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              OutlinedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false),
                child: const Text('Back to start'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SMALL REUSABLE PIECES
// ---------------------------------------------------------------------------

// A bold label above a text field.
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(text,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface)),
    );
  }
}

// A tappable role card that highlights when selected.
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? cs.primary : const Color(0xFFDDE3E1),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 30,
                color: selected ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: selected ? cs.primary : cs.onSurface)),
          ],
        ),
      ),
    );
  }
}

// Quick helper to show a bottom message.
void _showSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));
}
