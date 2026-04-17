import 'package:flutter/material.dart';

class ScreenExplore extends StatefulWidget {
  const ScreenExplore({super.key});

  @override
  State<ScreenExplore> createState() => _ScreenExploreState();
}

class _QuickTool {
  final IconData icon;
  final String label;
  final Color color;
  final String? id;
  const _QuickTool(this.icon, this.label, this.color, [this.id]);
}

class _ListItem {
  final IconData icon;
  final String label;
  final String desc;
  const _ListItem(this.icon, this.label, this.desc);
}

class _LearnCard {
  final IconData icon;
  final String label;
  final String desc;
  final List<Color> gradient;
  final Color border;
  const _LearnCard(
    this.icon,
    this.label,
    this.desc,
    this.gradient,
    this.border,
  );
}

class _Rule {
  final String key;
  final String title;
  final String desc;
  const _Rule(this.key, this.title, this.desc);
}

class _ScreenExploreState extends State<ScreenExplore> {
  final Map<String, bool> rules = {
    'maxDailyLoss': true,
    'stopLossRequired': true,
    'maxPositionSize': false,
    'noRevengeTrading': true,
    'followStrategy': true,
  };

  static const _quickTools = [
    _QuickTool(
      Icons.format_list_numbered,
      'Trading Rules',
      Color(0xFF8B5CF6),
      'trading-rules',
    ),
    _QuickTool(Icons.tune, 'Risk Rules', Color(0xFF1AA3E6)),
    _QuickTool(Icons.workspace_premium, 'Strategies', Color(0xFFE6B800)),
    _QuickTool(Icons.gps_fixed, 'Goals', Color(0xFF22C55E)),
  ];

  static const _managementItems = [
    _ListItem(
      Icons.calendar_month,
      'Scheduled Trades',
      'Plan your upcoming trades',
    ),
    _ListItem(Icons.tag, 'Tags & Labels', 'Organize trades with tags'),
  ];

  static final _learnCards = [
    _LearnCard(
      Icons.menu_book,
      'Journal Tips',
      'Master your trading journal',
      [const Color(0xFF3D2A66), const Color(0xFF1F1438)],
      const Color(0x4D7C5BC9),
    ),
    _LearnCard(
      Icons.psychology,
      'Psychology',
      'Master your trading mind',
      [const Color(0xFF143A52), const Color(0xFF0B2233)],
      const Color(0x4D2E7BB3),
    ),
    _LearnCard(
      Icons.bar_chart,
      'Chart Patterns',
      'Identify key patterns',
      [const Color(0xFF1A4A2E), const Color(0xFF0C2818)],
      const Color(0x4D2E9659),
    ),
    _LearnCard(
      Icons.lightbulb_outline,
      'Daily Ideas',
      'Fresh trading setups',
      [const Color(0xFF584320), const Color(0xFF2E2310)],
      const Color(0x4DB39B40),
    ),
  ];

  static const _moreLearnItems = [
    _ListItem(Icons.school, 'Trading Courses', 'Structured learning paths'),
    _ListItem(
      Icons.play_circle_outline,
      'Video Tutorials',
      'Watch & learn techniques',
    ),
    _ListItem(Icons.article, 'Market News', 'Stay updated on markets'),
  ];

  static const _rulesList = [
    _Rule(
      'maxDailyLoss',
      'Max Daily Loss Limit',
      'Stop trading after reaching daily loss limit',
    ),
    _Rule(
      'stopLossRequired',
      'Stop Loss Required',
      'Must set stop loss before entering trade',
    ),
    _Rule(
      'maxPositionSize',
      'Max Position Size',
      'Limit position size to percentage of capital',
    ),
    _Rule(
      'noRevengeTrading',
      'No Revenge Trading',
      'Wait cooldown period after consecutive losses',
    ),
    _Rule(
      'followStrategy',
      'Follow Strategy',
      'Only take trades that match your strategy',
    ),
  ];

  void _onToolTap(String? id) {
    if (id == 'trading-rules') _openTradingRules();
  }

  void _openTradingRules() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B0B0F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => FractionallySizedBox(
          heightFactor: 0.85,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trading Rules',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: _rulesList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final r = _rulesList[i];
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    r.desc,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: rules[r.key]!,
                              onChanged: (v) {
                                setSheet(() => rules[r.key] = v);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Explore',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tools, learning & community',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),

              // Quick Tools
              Row(
                children: _quickTools.map((t) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => _onToolTap(t.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: t.color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: t.color.withOpacity(0.15),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: t.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(t.icon, color: t.color, size: 20),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Premium Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE6B800).withOpacity(0.12),
                      const Color(0xFF8B5CF6).withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE6B800).withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFC107), Color(0xFFCC8A1F)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Unlock Premium',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'All features, unlimited analytics',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.white.withOpacity(0.2),
                      size: 16,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _sectionLabel('TRADING MANAGEMENT'),
              const SizedBox(height: 12),
              ..._managementItems.map(
                (it) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _glassListTile(it.icon, it.label, it.desc),
                ),
              ),
              const SizedBox(height: 16),

              _sectionLabel('LEARN & IMPROVE'),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: _learnCards
                    .map(
                      (c) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: c.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: c.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              c.icon,
                              color: Colors.white.withOpacity(0.6),
                              size: 24,
                            ),
                            const Spacer(),
                            Text(
                              c.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c.desc,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),

              // More learning grouped card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  children: List.generate(_moreLearnItems.length, (i) {
                    final it = _moreLearnItems[i];
                    return Column(
                      children: [
                        _innerListTile(it.icon, it.label, it.desc),
                        if (i != _moreLearnItems.length - 1)
                          Divider(
                            height: 1,
                            color: Colors.white.withOpacity(0.06),
                          ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),

              _sectionLabel('COMMUNITY'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _communityCard(
                      Icons.people,
                      'Community',
                      'Connect with traders',
                      [const Color(0xFF1F3357), const Color(0xFF132037)],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _communityCard(
                      Icons.description,
                      'Strategies',
                      'Shared by the community',
                      [const Color(0xFF3A1F4D), const Color(0xFF20132E)],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.4),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    ),
  );

  Widget _glassListTile(IconData icon, String label, String desc) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.03),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.06)),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white.withOpacity(0.5), size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: Colors.white.withOpacity(0.15),
          size: 18,
        ),
      ],
    ),
  );

  Widget _innerListTile(IconData icon, String label, String desc) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white.withOpacity(0.5), size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: Colors.white.withOpacity(0.15),
          size: 18,
        ),
      ],
    ),
  );

  Widget _communityCard(
    IconData icon,
    String title,
    String desc,
    List<Color> gradient,
  ) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: gradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.5), size: 24),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
        ),
      ],
    ),
  );
}
