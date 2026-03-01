import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../../utils/app_colors.dart';

class PostFormFields extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final PostCategory selectedCategory;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final bool isAnonymous;
  final Function(PostCategory?) onCategoryChanged;
  final Function(bool) onAnonymousChanged;

  const PostFormFields({
    super.key,
    required this.formKey,
    required this.selectedCategory,
    required this.titleController,
    required this.contentController,
    required this.isAnonymous,
    required this.onCategoryChanged,
    required this.onAnonymousChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 카테고리 선택 드롭다운
          DropdownButtonFormField<PostCategory>(
            value: selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            // [수정] 단순 enum 이름을 대문자로 바꾸는 대신, 모델에 정의된 label(General 등)을 사용합니다.
            items: PostCategory.values.where((c) => c != PostCategory.hot).map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Text(cat.label), // 이제 'Lounge' 대신 'General'로 표시됩니다.
              );
            }).toList(),
            onChanged: onCategoryChanged,
          ),
          const SizedBox(height: 20),

          // 제목 입력
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Enter title for exchange students',
              border: OutlineInputBorder(),
            ),
            validator: (v) => v!.isEmpty ? 'Please enter title' : null,
          ),
          const SizedBox(height: 20),

          // 본문 입력
          TextFormField(
            controller: contentController,
            decoration: const InputDecoration(
              labelText: 'Content',
              hintText: 'Share information or ask questions...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            maxLines: null,
            minLines: 8,
            textAlignVertical: TextAlignVertical.top,
            validator: (v) => v!.isEmpty ? 'Please enter content' : null,
          ),
          const SizedBox(height: 20),

          // 익명 토글
          CheckboxListTile(
            title: const Text(
              "Post Anonymously",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            value: isAnonymous,
            activeColor: AppColors.knuRed,
            onChanged: (val) => onAnonymousChanged(val ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
}