import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/status_post.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../theme.dart';
import '../widgets/status_card.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key, required this.userId});
  final int userId;

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  AppUser? _user;
  final List<StatusPost> _statuses = [];
  int _offset = 0;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _total = 0;
  String? _error;
  bool _busyFollow = false;

  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAll();
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      final user = await api.getUser(widget.userId);
      final page = await api.getUserStatuses(widget.userId);
      if (!mounted) return;
      setState(() {
        _user = user;
        _statuses
          ..clear()
          ..addAll(page.items);
        _offset = page.items.length;
        _hasMore = page.hasMore;
        _total = page.total;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de charger le profil';
        _loading = false;
      });
    }
  }

  Future<void> _maybeLoadMore() async {
    if (_loadingMore || !_hasMore) return;
    if (_scroll.position.pixels < _scroll.position.maxScrollExtent - 240) {
      return;
    }
    setState(() => _loadingMore = true);
    try {
      final api = ref.read(apiClientProvider);
      final page = await api.getUserStatuses(
        widget.userId,
        offset: _offset,
        limit: 20,
      );
      if (!mounted) return;
      setState(() {
        _statuses.addAll(page.items);
        _offset += page.items.length;
        _hasMore = page.hasMore;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  Future<void> _toggleFollow() async {
    final u = _user;
    if (u == null || u.isMe || _busyFollow) return;
    setState(() {
      _busyFollow = true;
      _user = u.copyWith(isFollowing: !u.isFollowing);
    });
    try {
      final api = ref.read(apiClientProvider);
      if (u.isFollowing) {
        await api.unfollow(u.id);
      } else {
        await api.follow(u.id);
      }
    } catch (_) {
      // rollback
      if (!mounted) return;
      setState(() => _user = u);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Échec — réessaie dans un instant')),
      );
    } finally {
      if (mounted) setState(() => _busyFollow = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: CustomScrollView(
          controller: _scroll,
          slivers: [
            _AppBar(user: user),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: FanPitchColors.muted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(color: FanPitchColors.muted),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _loadAll,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              )
            else if (user != null) ...[
              SliverToBoxAdapter(
                child: _Header(user: user, postsCount: _total),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: _FollowRow(
                    user: user,
                    busy: _busyFollow,
                    onToggle: _toggleFollow,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        'Publications',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      Text(
                        '$_total',
                        style: const TextStyle(
                          color: FanPitchColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_statuses.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 60),
                    child: _EmptyPosts(isMe: user.isMe),
                  ),
                )
              else
                SliverList.separated(
                  itemCount: _statuses.length + (_hasMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (_, i) {
                    if (i == _statuses.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: StatusCard(status: _statuses[i]),
                    );
                  },
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 60)),
            ],
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final AppUser? user;
  const _AppBar({required this.user});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      title: Text(
        user?.profile.displayName.isNotEmpty == true
            ? user!.profile.displayName
            : user?.username ?? 'Profil',
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).maybePop().then((handled) {
          if (!handled && context.mounted) context.go('/');
        }),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppUser user;
  final int postsCount;
  const _Header({required this.user, required this.postsCount});

  @override
  Widget build(BuildContext context) {
    final p = user.profile;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Brand gradient banner
        Container(
          height: 120,
          decoration: BoxDecoration(gradient: context.fp.brandGradient),
        ),
        // Avatar + info
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 70, 20, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Avatar(user: user, size: 96),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.displayName.isNotEmpty
                            ? p.displayName
                            : user.username,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      Text(
                        '@${user.username}',
                        style: const TextStyle(
                          color: FanPitchColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 184, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (p.bio != null && p.bio!.isNotEmpty)
                Text(
                  p.bio!,
                  style: const TextStyle(fontSize: 14, height: 1.45),
                ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (p.country != null && p.country!.isNotEmpty)
                    _Chip(icon: Icons.public_rounded, label: p.country!),
                  _Chip(icon: Icons.stars_rounded, label: '${p.points} pts'),
                  _Chip(
                    icon: Icons.trending_up_rounded,
                    label: 'Lvl ${p.level}',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat(value: postsCount, label: 'posts'),
                  _Stat(value: p.followerCount, label: 'abonnés'),
                  _Stat(value: p.followingCount, label: 'suivis'),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final AppUser user;
  final double size;
  const _Avatar({required this.user, required this.size});

  @override
  Widget build(BuildContext context) {
    final url = user.profile.avatarUrl;
    final initials =
        (user.profile.displayName.isNotEmpty
                ? user.profile.displayName
                : user.username)
            .substring(0, 1)
            .toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: context.fp.brandGradient,
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: url != null && url.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _initialBubble(initials, size),
              )
            : _initialBubble(initials, size),
      ),
    );
  }

  Widget _initialBubble(String initials, double s) => Center(
    child: Text(
      initials,
      style: TextStyle(
        color: Colors.white,
        fontSize: s * 0.42,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: FanPitchColors.muted),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final int value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _fmt(value),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: FanPitchColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _FollowRow extends StatelessWidget {
  final AppUser user;
  final bool busy;
  final VoidCallback onToggle;
  const _FollowRow({
    required this.user,
    required this.busy,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (user.isMe) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Modifier mon profil'),
              onPressed: () {
                // TODO: navigate to edit profile screen
              },
            ),
          ),
        ],
      );
    }

    final following = user.isFollowing;
    return Row(
      children: [
        Expanded(
          child: following
              ? OutlinedButton(
                  onPressed: busy ? null : onToggle,
                  child: busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Abonné  ✓'),
                )
              : FilledButton(
                  onPressed: busy ? null : onToggle,
                  child: busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('S\'abonner'),
                ),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Messagerie à venir bientôt')),
            );
          },
          child: const Icon(Icons.send_outlined, size: 18),
        ),
      ],
    );
  }
}

class _EmptyPosts extends StatelessWidget {
  final bool isMe;
  const _EmptyPosts({required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 56,
            color: FanPitchColors.muted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            isMe
                ? 'Tu n\'as encore rien publié.'
                : 'Aucune publication pour le moment.',
            style: const TextStyle(
              color: FanPitchColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isMe) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Créer une publication'),
              onPressed: () => context.push('/status/new'),
            ),
          ],
        ],
      ),
    );
  }
}
