import 'package:flutter/material.dart';
import 'package:hello_flutter/constants/incident_categories.dart';
import 'package:hello_flutter/models/incident.dart';
import 'package:hello_flutter/services/sentinel_api.dart';
import 'package:hello_flutter/theme/sentinel_colors.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final SentinelApi _api = SentinelApi();
  List<Incident> _incidents = [];
  bool _loading = true;
  Incident? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await _api.fetchNearbyIncidents();
      if (!mounted) return;
      setState(() {
        _incidents = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: sentinelAccent),
            SizedBox(height: 12),
            Text('Loading incidents...', style: TextStyle(color: Colors.white38)),
          ],
        ),
      );
    }

    final verified = _incidents.where((i) => i.status == 'verified').length;
    final pending = _incidents.where((i) => i.status == 'pending').length;

    return ColoredBox(
      color: sentinelBackground,
      child: Column(
        children: [
          _StatsBar(
            total: _incidents.length,
            verified: verified,
            pending: pending,
          ),
          if (_selected != null) _DetailCard(
            incident: _selected!,
            onClose: () => setState(() => _selected = null),
          ),
          Expanded(
            child: _incidents.isEmpty
                ? RefreshIndicator(
                    color: sentinelAccent,
                    onRefresh: _load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Icon(
                            Icons.shield_outlined,
                            size: 48,
                            color: Colors.white30,
                          ),
                        ),
                        SizedBox(height: 12),
                        Center(
                          child: Text(
                            'No incidents in the last 48 hours',
                            style: TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: sentinelAccent,
                    onRefresh: _load,
                    child: ListView.builder(
                      itemCount: _incidents.length,
                      itemBuilder: (context, index) {
                        final item = _incidents[index];
                        final config = categoryForId(item.category);
                        final selected = _selected?.id == item.id;
                        return InkWell(
                          onTap: () => setState(() {
                            _selected = selected ? null : item;
                          }),
                          child: Container(
                            color: selected
                                ? Colors.white.withValues(alpha: 0.03)
                                : null,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: config.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: config.color.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Icon(
                                    config.icon,
                                    color: config.color,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            config.label.toUpperCase(),
                                            style: TextStyle(
                                              color: config.color,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          Text(
                                            timeAgo(item.createdAt),
                                            style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: sentinelText,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item.status.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 9,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle_outline,
                                                size: 12,
                                                color: Colors.green.shade400,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${item.confirmationCount}',
                                                style: TextStyle(
                                                  color: Colors.green.shade400,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
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
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.total,
    required this.verified,
    required this.pending,
  });

  final int total;
  final int verified;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: sentinelSurface,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _Stat(value: '$total', label: 'TOTAL', color: sentinelAccent),
          _Stat(value: '$verified', label: 'VERIFIED', color: sentinelBlue),
          _Stat(value: '$pending', label: 'PENDING', color: Color(0xFFF97316)),
          const _Stat(value: '48h', label: 'WINDOW', color: Color(0xFF10B981)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.incident, required this.onClose});

  final Incident incident;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final config = categoryForId(incident.category);
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: sentinelSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(config.icon, color: config.color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      style: const TextStyle(
                        color: sentinelText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${timeAgo(incident.createdAt)} · ${incident.status.toUpperCase()}',
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, color: Colors.white38),
              ),
            ],
          ),
          if (incident.description != null && incident.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              incident.description!,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.check_circle_outline, size: 14, color: Colors.green.shade400),
              const SizedBox(width: 4),
              Text(
                '${incident.confirmationCount} confirmation${incident.confirmationCount == 1 ? '' : 's'}',
                style: TextStyle(
                  color: Colors.green.shade400,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
