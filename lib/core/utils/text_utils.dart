/// TVMaze summaries contain HTML like `<p><b>Title</b> text</p>`.
/// This removes the tags and decodes the common entities.
/// Returns null when there is no text left.
String? stripHtml(String? html) {
  if (html == null) return null;
  final text = html
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .trim();
  return text.isEmpty ? null : text;
}
