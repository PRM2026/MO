import 'package:flutter/material.dart';

import '../repositories/auth_repository.dart';
import '../routes/app_routes.dart';
import '../utils/app_toast.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key, this.repository});

  final AuthRepository? repository;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late final AuthRepository _repository;
  bool _isLoading = true;
  bool _isLoggingOut = false;
  String? _token;
  String? _email;
  String? _fullName;
  String? _role;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? AuthRepository();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _repository.loadProfile();
    if (!mounted) return;
    setState(() {
      _token = profile.token;
      _email = profile.email;
      _fullName = profile.fullName;
      _role = profile.role;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    await _repository.logout();
    if (!mounted) return;
    setState(() => _isLoggingOut = false);
    AppToast.showSuccess(context, 'Đã đăng xuất');
    AppRoutes.openAfterLogout(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('Tài khoản'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _fullName?.isNotEmpty == true ? _fullName! : 'Đã đăng nhập',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_email?.isNotEmpty == true)
                    Text(
                      _email!,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  if (_role?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Vai trò: $_role',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'JWT Token',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: SelectableText(
                          _token?.isNotEmpty == true ? _token! : 'Không có token',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_role?.toUpperCase() == 'JOCKEY') ...[
                    FilledButton(
                      onPressed: () => AppRoutes.openJockeyPortal(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF15130F),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Vào portal jockey',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_role?.toUpperCase() == 'REFEREE') ...[
                    FilledButton(
                      onPressed: () => AppRoutes.openRefereePortal(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0C1D36),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Vào portal trọng tài',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  OutlinedButton(
                    onPressed: _isLoggingOut ? null : _handleLogout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoggingOut
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Đăng xuất',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
