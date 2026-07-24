import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../services/admin_api_service.dart';
import '../../widgets/admin/admin_dialogs.dart';
import '../../widgets/admin/admin_ui.dart';

class AdminNewsScreen extends StatefulWidget {
  const AdminNewsScreen({super.key});

  @override
  State<AdminNewsScreen> createState() => _AdminNewsScreenState();
}

class _AdminNewsScreenState extends State<AdminNewsScreen> {
  final AdminApiService _service = AdminApiService();
  final TextEditingController _search = TextEditingController();
  List<JsonMap> _articles = const [];
  bool _loading = true;
  String? _busyId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final articles = await _service.getNews();
      if (mounted) setState(() => _articles = articles);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<JsonMap> get _visible {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return _articles;
    return _articles
        .where(
          (article) => [
            adminText(article, 'title'),
            adminText(article, 'summary'),
            adminText(article, 'shortDescription'),
            adminText(article, 'category'),
          ].join(' ').toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> _openForm([JsonMap? article]) async {
    final result = await showModalBottomSheet<_NewsFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AdminPalette.navyLight,
      builder: (_) => _NewsFormSheet(article: article),
    );
    if (result == null || !mounted) return;
    try {
      if (article == null) {
        await _service.createNews(result.payload, imagePath: result.imagePath);
      } else {
        await _service.updateNews(
          adminText(article, 'id'),
          result.payload,
          imagePath: result.imagePath,
        );
      }
      if (!mounted) return;
      showAdminMessage(
        context,
        article == null ? 'Đã tạo bài viết.' : 'Đã cập nhật bài viết.',
      );
      await _load();
    } catch (error) {
      if (mounted) showAdminMessage(context, '$error', error: true);
    }
  }

  Future<void> _delete(JsonMap article) async {
    final confirmed = await showAdminConfirm(
      context,
      title: 'Xóa bài viết?',
      message: 'Thao tác này sẽ xóa bài viết khỏi hệ thống.',
      confirmLabel: 'Xóa',
      danger: true,
    );
    if (!confirmed || !mounted) return;
    final id = adminText(article, 'id');
    setState(() => _busyId = id);
    try {
      await _service.deleteNews(id);
      if (!mounted) return;
      showAdminMessage(context, 'Đã xóa bài viết.');
      await _load();
    } catch (error) {
      if (mounted) showAdminMessage(context, '$error', error: true);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminRefreshHost(
      onRefresh: _load,
      child: AdminPage(
        title: 'Tin tức',
        subtitle: 'Tạo, chỉnh sửa và xuất bản nội dung truyền thông',
        action: IconButton.filled(
          tooltip: 'Tạo bài viết',
          style: IconButton.styleFrom(
            backgroundColor: AdminPalette.gold,
            foregroundColor: AdminPalette.navy,
          ),
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add_rounded),
        ),
        child: _body(),
      ),
    );
  }

  Widget _body() {
    if (_loading && _articles.isEmpty) return const AdminLoading();
    if (_error != null && _articles.isEmpty) {
      return AdminErrorCard(message: _error!, onRetry: _load);
    }
    return Column(
      children: [
        TextField(
          controller: _search,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Tìm tiêu đề, nội dung, danh mục...',
            hintStyle: const TextStyle(color: AdminPalette.muted),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AdminPalette.muted,
            ),
            filled: true,
            fillColor: AdminPalette.card,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 14),
        if (_visible.isEmpty)
          const AdminEmptyState(message: 'Chưa có bài viết')
        else
          ..._visible.map(_articleCard),
      ],
    );
  }

  Widget _articleCard(JsonMap article) {
    final id = adminText(article, 'id');
    final image = adminText(
      article,
      'imageUrl',
      adminText(article, 'thumbnail'),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AdminCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  image,
                  height: 145,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AdminStatusChip(
                        adminText(article, 'category', 'Tin tức'),
                      ),
                      if (article['featured'] == true) ...[
                        const SizedBox(width: 8),
                        const AdminStatusChip('NỔI BẬT'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    adminText(article, 'title', 'Bài viết'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    adminText(
                      article,
                      'summary',
                      adminText(article, 'shortDescription'),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AdminPalette.muted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        _date(
                          adminText(
                            article,
                            'publishedAt',
                            adminText(article, 'createdAt'),
                          ),
                        ),
                        style: const TextStyle(
                          color: AdminPalette.muted,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Chỉnh sửa',
                        onPressed: _busyId == id
                            ? null
                            : () => _openForm(article),
                        icon: const Icon(
                          Icons.edit_rounded,
                          color: AdminPalette.info,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Xóa',
                        onPressed: _busyId == id
                            ? null
                            : () => _delete(article),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AdminPalette.danger,
                        ),
                      ),
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

  String _date(String value) =>
      value.length >= 10 ? value.substring(0, 10) : 'Chưa cập nhật';
}

class _NewsFormResult {
  const _NewsFormResult(this.payload, this.imagePath);

  final JsonMap payload;
  final String? imagePath;
}

class _NewsFormSheet extends StatefulWidget {
  const _NewsFormSheet({this.article});

  final JsonMap? article;

  @override
  State<_NewsFormSheet> createState() => _NewsFormSheetState();
}

class _NewsFormSheetState extends State<_NewsFormSheet> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _summary;
  late final TextEditingController _content;
  late final TextEditingController _category;
  bool _featured = false;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final article = widget.article ?? const <String, dynamic>{};
    _title = TextEditingController(text: adminText(article, 'title'));
    _summary = TextEditingController(
      text: adminText(
        article,
        'summary',
        adminText(article, 'shortDescription'),
      ),
    );
    _content = TextEditingController(text: adminText(article, 'content'));
    _category = TextEditingController(
      text: adminText(article, 'category', 'Tin tức'),
    );
    _featured = article['featured'] == true;
  }

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    _content.dispose();
    _category.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    final path = result?.files.single.path;
    if (path != null) setState(() => _imagePath = path);
  }

  void _save() {
    if (!_key.currentState!.validate()) return;
    Navigator.pop(
      context,
      _NewsFormResult({
        'title': _title.text.trim(),
        'summary': _summary.text.trim(),
        'content': _content.text.trim(),
        'category': _category.text.trim(),
        'featured': _featured,
        if (widget.article == null)
          'publishedAt': DateTime.now().toIso8601String(),
      }, _imagePath),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          18,
          18,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.article == null
                      ? 'Tạo bài viết'
                      : 'Chỉnh sửa bài viết',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                _field(_title, 'Tiêu đề', required: true),
                _field(_summary, 'Mô tả ngắn', maxLines: 3, required: true),
                _field(_content, 'Nội dung', maxLines: 8, required: true),
                _field(_category, 'Danh mục', required: true),
                SwitchListTile.adaptive(
                  value: _featured,
                  onChanged: (value) => setState(() => _featured = value),
                  title: const Text(
                    'Tin nổi bật',
                    style: TextStyle(color: Colors.white),
                  ),
                  activeTrackColor: AdminPalette.gold,
                ),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(
                    _imagePath == null ? 'Chọn ảnh bài viết' : 'Đã chọn ảnh',
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: AdminPrimaryButton(
                    label: widget.article == null ? 'Đăng bài' : 'Lưu thay đổi',
                    icon: Icons.save_rounded,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        validator: required
            ? (value) =>
                  value == null || value.trim().isEmpty ? 'Bắt buộc' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AdminPalette.muted),
          alignLabelWithHint: maxLines > 1,
          filled: true,
          fillColor: AdminPalette.card,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
