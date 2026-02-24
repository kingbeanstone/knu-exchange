import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class CommunitySearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onClear;

  const CommunitySearchBar({
    super.key,
    required this.onSearch,
    required this.onClear,
  });

  @override
  State<CommunitySearchBar> createState() => _CommunitySearchBarState();
}

class _CommunitySearchBarState extends State<CommunitySearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    // 텍스트 변경 리스너 등록
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  // [수정] 텍스트가 비었을 때 자동으로 검색을 취소하는 로직 추가
  void _onTextChanged() {
    final text = _controller.text;

    // X 버튼 노출 여부 업데이트
    setState(() {
      _showClearButton = text.isNotEmpty;
    });

    // 입력창이 비어있으면 즉시 목록 초기화 콜백 호출
    if (text.isEmpty) {
      widget.onClear();
    }
  }

  void _handleSearch() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      widget.onSearch(query);
    }
  }

  void _handleClear() {
    _controller.clear();
    // 리스너(_onTextChanged)에 의해 widget.onClear()가 자동으로 호출됩니다.
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: TextField(
        controller: _controller,
        onSubmitted: (_) => _handleSearch(),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: "Search posts by title...",
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _showClearButton
              ? IconButton(
            icon: const Icon(Icons.cancel, color: Colors.grey),
            onPressed: _handleClear,
          )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.knuRed.withOpacity(0.5)),
          ),
        ),
      ),
    );
  }
}