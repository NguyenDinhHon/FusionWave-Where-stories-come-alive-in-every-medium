import 'package:flutter/material.dart';

class StatsMockupPage extends StatelessWidget {
  const StatsMockupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Statistics'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewRow(),
              const SizedBox(height: 18),
              _buildTimeSeriesCard(),
              const SizedBox(height: 18),
              _buildHeatmapCard(),
              const SizedBox(height: 18),
              _buildPerBookList(),
              const SizedBox(height: 18),
              _buildTopAuthors(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        _OverviewCard(title: 'Books', value: '12', subtitle: 'Completed'),
        _OverviewCard(title: 'Pages', value: '4,320', subtitle: 'Total'),
        _OverviewCard(title: 'Time', value: '72h', subtitle: 'Read'),
        _OverviewCard(title: 'Streak', value: '9', subtitle: 'Days'),
      ],
    );
  }

  Widget _buildTimeSeriesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Last 30 days', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(30, (i) {
                  final height = (10 + (i % 7) * 12).toDouble();
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [Text('0'), Text('15'), Text('30')],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Activity heatmap', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: GridView.builder(
                itemCount: 42,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemBuilder: (ctx, idx) {
                  final level = (idx % 5);
                  final color = Colors.green[(100 + level * 100).clamp(100, 900)];
                  return Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerBookList() {
    final books = List.generate(4, (i) => {
          'title': 'Book ${i + 1}',
          'author': 'Author ${i + 1}',
          'progress': (20 + i * 20),
        });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 6, bottom: 8),
          child: Text('Reading progress', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ...books.map((b) {
          final p = b['progress'] as int;
          return Card(
            child: ListTile(
              title: Text((b['title'] ?? '').toString()),
              subtitle: Text((b['author'] ?? '').toString()),
              trailing: SizedBox(
                width: 96,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$p%'),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(value: p / 100),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTopAuthors() {
    final authors = ['A. Nguyen', 'B. Tran', 'C. Le', 'D. Pham'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 6, bottom: 8),
          child: Text('Top authors', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: authors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) => Container(
              width: 140,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(authors[i], style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('${10 - i} books', style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _OverviewCard({required this.title, required this.value, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(title, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black45)),
            ],
          ),
        ),
      ),
    );
  }
}
