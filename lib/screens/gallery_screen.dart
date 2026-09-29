import 'package:flutter/material.dart';

import '../ads/ad_manager.dart';
import '../art/pictures.dart';
import '../l10n/strings.dart';
import '../services/coloring_store.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/parental_gate.dart';
import '../widgets/picture_painter.dart';
import 'coloring_screen.dart';

/// 그림 고르기 화면: 팩별 썸네일 격자. 잠긴 팩은 부모 확인 → 보상형 광고로 연다.
/// 배너는 이 화면에만 둔다 (색칠 중 실수로 누르지 않도록).
class GalleryScreen extends StatelessWidget {
  final ColoringStore store;
  const GalleryScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.appTitle, style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: s.language,
            icon: const Icon(Icons.language_rounded),
            onPressed: () => _showLanguage(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => CustomScrollView(
          slivers: [
            for (var pack = 0; pack < packCount; pack++) ...[
              SliverToBoxAdapter(
                child: _PackHeader(store: store, pack: pack),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [for (final p in pictures.where((p) => p.pack == pack)) _Thumb(store: store, picture: p)],
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }

  Future<void> _showLanguage(BuildContext context) async {
    final s = S.of(context);
    final controller = LocaleController.of(context);
    final picked = await showDialog<Locale?>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(s.language),
        children: [
          RadioGroup<Locale?>(
            groupValue: controller.value,
            onChanged: (v) => Navigator.pop(ctx, v ?? const Locale('und')),
            child: Column(
              children: [
                for (final l in <Locale?>[null, ...S.supported])
                  RadioListTile<Locale?>(value: l, title: Text(l == null ? s.systemLanguage : S.nativeName(l))),
              ],
            ),
          ),
        ],
      ),
    );
    if (picked == null) return;
    controller.value = picked.languageCode == 'und' ? null : picked;
  }
}

/// 팩 이름. 잠겨 있으면 자물쇠 버튼(부모 확인 → 광고 → 열기).
class _PackHeader extends StatelessWidget {
  final ColoringStore store;
  final int pack;
  const _PackHeader({required this.store, required this.pack});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final unlocked = store.isUnlocked(pack);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(s.packNames[pack], style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          ),
          if (!unlocked)
            FilledButton.tonalIcon(
              icon: const Icon(Icons.lock_rounded),
              label: Text(s.locked),
              onPressed: () => unlockPack(context, store, pack),
            ),
        ],
      ),
    );
  }
}

/// 잠긴 팩 열기: 부모 확인 → 안내 → 보상형 광고 → 끝까지 보면 열림.
Future<void> unlockPack(BuildContext context, ColoringStore store, int pack) async {
  if (!await showParentalGate(context) || !context.mounted) return;
  final s = S.of(context);
  final name = s.packNames[pack];
  final go = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(name),
      content: Text(s.unlockBody(name)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
        FilledButton.icon(
          icon: const Icon(Icons.ondemand_video_rounded),
          label: Text(s.watchAd),
          onPressed: () => Navigator.pop(ctx, true),
        ),
      ],
    ),
  );
  if (go != true || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  final shown = AdManager.instance.showRewarded(
    onReward: () {
      store.unlock(pack);
      messenger.showSnackBar(SnackBar(content: Text(s.unlocked(name))));
    },
  );
  if (!shown) messenger.showSnackBar(SnackBar(content: Text(s.adNotReady)));
}

class _Thumb extends StatelessWidget {
  final ColoringStore store;
  final Picture picture;
  const _Thumb({required this.store, required this.picture});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final unlocked = store.isUnlocked(picture.pack);
    final done = store.isComplete(picture);
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (!unlocked) {
            unlockPack(context, store, picture.pack);
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ColoringScreen(store: store, picture: picture),
            ),
          );
        },
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CustomPaint(painter: PicturePainter(picture, store.fillsOf(picture), strokeWidth: 10)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    s.pictureName(picture.id),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ],
            ),
            if (done) const Positioned(top: 6, right: 6, child: Text('⭐', style: TextStyle(fontSize: 26))),
            if (!unlocked)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  alignment: Alignment.center,
                  child: const Icon(Icons.lock_rounded, color: Colors.white, size: 44),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
