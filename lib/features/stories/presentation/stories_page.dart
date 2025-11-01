import 'package:flutter/material.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: 3,
        itemBuilder: (context, index) {
          return _StoryView(index: index);
        },
      ),
    );
  }
}

class _StoryView extends StatelessWidget {
  const _StoryView({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: Center(
            child: Text(
              'قصة رقم ${index + 1}',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Positioned(
          top: 48,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(Icons.favorite_border, color: Colors.white),
              Icon(Icons.send, color: Colors.white),
            ],
          ),
        ),
        Positioned(
          bottom: 32,
          left: 16,
          right: 16,
          child: Row(
            children: const [
              CircleAvatar(child: Icon(Icons.person)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'تفاعل مع القصة محليًا',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Icon(Icons.more_vert, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }
}
