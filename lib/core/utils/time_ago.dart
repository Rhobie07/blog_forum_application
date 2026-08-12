String timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y';
  if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo';
  if (diff.inDays > 0) return '${diff.inDays}d';
  if (diff.inHours > 0) return '${diff.inHours}h';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m';
  return 'now';
}
