import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../models/binance_models.dart';
import '../services/news_service.dart';
import '../widgets/glass_card.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _newsService = NewsService();
  List<CryptoNews> _news = [];
  bool _loading = true;
  String? _error;
  String _activeCategory = '';

  static const _categories = [
    ('ALL', ''),
    ('BTC', 'BTC'),
    ('ETH', 'ETH'),
    ('SOL', 'SOL'),
    ('DeFi', 'DeFi'),
    ('NFT', 'NFT'),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadNews();
  }

  Future<void> _loadNews({String category = ''}) async {
    setState(() {
      _loading = true;
      _error = null;
      _activeCategory = category;
    });
    final news = await _newsService.fetchNews(category: category.isEmpty ? null : category);
    if (!mounted) return;
    setState(() {
      _news = news;
      _loading = false;
      if (news.isEmpty) _error = 'No news available';
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.2,
            colors: [Color(0xFF0A0B1E), AppTheme.bgMain],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              TabBar(
                controller: _tabs,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.textMuted,
                indicatorColor: AppTheme.primary,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1),
                tabs: const [
                  Tab(text: 'CRYPTO NEWS'),
                  Tab(text: 'TRADING TIPS'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _buildNewsTab(),
                    _buildTipsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Market Intel',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                Text('News & Pro Trading Tips',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary),
            onPressed: () => _loadNews(category: _activeCategory),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsTab() {
    return Column(
      children: [
        _buildCategoryChips(),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : _error != null
                  ? _buildError()
                  : RefreshIndicator(
                      color: AppTheme.primary,
                      backgroundColor: AppTheme.bgGlass,
                      onRefresh: () => _loadNews(category: _activeCategory),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        itemCount: _news.length,
                        itemBuilder: (_, i) => _buildNewsCard(_news[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: _categories.map((cat) {
          final selected = _activeCategory == cat.$2;
          return GestureDetector(
            onTap: () => _loadNews(category: cat.$2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary.withOpacity(0.18) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppTheme.primary.withOpacity(0.6) : Colors.white12,
                ),
              ),
              child: Text(
                cat.$1,
                style: TextStyle(
                  color: selected ? AppTheme.primary : AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNewsCard(CryptoNews news) {
    return GestureDetector(
      onTap: () => _showNewsDetail(news),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Image.network(
                  news.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagePlaceholder(),
                ),
              )
            else
              _imagePlaceholder(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            news.sourceName,
                            style: const TextStyle(color: AppTheme.primary, fontSize: 9, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(news.timeAgo,
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: const Icon(Icons.article_rounded, color: Colors.white24, size: 28),
    );
  }

  void _showNewsDetail(CryptoNews news) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1627),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            if (news.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(news.imageUrl, height: 160, width: double.infinity,
                    fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
              ),
            const SizedBox(height: 16),
            Text(news.title,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, height: 1.4)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(news.sourceName,
                      style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 8),
                Text(news.timeAgo, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              news.body.isNotEmpty ? news.body : 'No content available.',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppTheme.textMuted, size: 40),
          const SizedBox(height: 12),
          Text(_error ?? 'Failed to load news',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _loadNews(category: _activeCategory),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      children: [
        _tipSection('RISK MANAGEMENT', Icons.shield_rounded, AppTheme.danger, _riskTips),
        _tipSection('TECHNICAL ANALYSIS', Icons.analytics_rounded, AppTheme.primary, _taTips),
        _tipSection('FUTURES & LEVERAGE', Icons.bolt_rounded, AppTheme.accent, _futuresTips),
        _tipSection('TRADING PSYCHOLOGY', Icons.psychology_rounded, const Color(0xFFF59E0B), _psychTips),
      ],
    );
  }

  Widget _tipSection(String title, IconData icon, Color color, List<String> tips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      color: color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            ],
          ),
        ),
        ...tips.asMap().entries.map((e) => _tipCard(e.key + 1, e.value, color)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _tipCard(int num, String tip, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color.withOpacity(0.5), width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Text('$num', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(tip, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
          ),
        ],
      ),
    );
  }

  static const _riskTips = [
    'Never risk more than 1-2% of your total portfolio on a single trade. This ensures you survive a losing streak.',
    'Always set a Stop Loss before entering. With 10x leverage, a 10% adverse move wipes your margin — protect first.',
    'Use position sizing based on your stop distance, not a fixed dollar amount. Smaller stop = larger position possible.',
    'Keep a Risk/Reward ratio of at least 1:2. Win 40% of trades and still be profitable with proper R/R.',
    'Reduce position size after 3 consecutive losses. The market may be in a choppy regime your system dislikes.',
  ];

  static const _taTips = [
    'Never rely on a single indicator. Use 3+ confirming signals before entering. Confluence = higher probability.',
    'Higher timeframes are more reliable. A 4H signal is stronger than a 15m signal — always check the D1 trend.',
    'Volume confirms price action. A breakout on low volume is likely to fail. Wait for volume surge confirmation.',
    'MACD crossovers near the zero line are stronger signals than crossovers far above/below it.',
    'Bollinger Band squeeze (bands converging) signals an imminent big move. Trade the breakout direction.',
    'EMA 200 is the most watched moving average by institutional traders. Price bouncing off EMA200 is powerful.',
  ];

  static const _futuresTips = [
    'Start with 3x leverage until you are consistently profitable. 10x is for advanced risk managers only.',
    'Funding rates matter. If funding is very positive (longs paying shorts), consider contrarian short setups.',
    'Liquidation price awareness: always check how far your liquidation is from entry before sizing a position.',
    'In trending markets, let winners run with trailing stops. In ranges, take profit at structure levels.',
    'Never average down on a leveraged futures trade. If price moves against you, your original thesis was wrong.',
  ];

  static const _psychTips = [
    'Follow your trading plan every single time. Discretionary overrides are where most losses come from.',
    'Keep a trading journal. Review it weekly to identify patterns in both winning and losing trades.',
    'Separate your net worth identity from your account balance. A single trade outcome does not define you.',
    'Take breaks after winning streaks too — overconfidence is as dangerous as fear after losses.',
    'If you feel anxious watching a position, your position size is too large. Reduce to a size you can sleep with.',
  ];
}
