import 'package:reeder/core/utils/bionic_reading.dart';

String buildArticle(int targetChars) {
  final b = StringBuffer();
  var i = 0;
  while (b.length < targetChars) {
    b.write(
      '<p>Paragraph $i: the quick brown fox jumps over the lazy dog, '
      'and reads some <a href="https://example.com">interesting</a> content '
      'about RSS feeds and mobile readers. 中文段落测试，阅读器正文渲染。</p>',
    );
    i++;
  }
  return b.toString();
}

void main() {
  for (final size in [10 * 1024, 50 * 1024, 200 * 1024]) {
    final html = buildArticle(size);

    // warm up
    BionicReading.applyToHtml(html);

    final sw = Stopwatch()..start();
    const runs = 10;
    for (var i = 0; i < runs; i++) {
      BionicReading.applyToHtml(html);
    }
    sw.stop();

    print(
      '${(html.length / 1024).toStringAsFixed(0).padLeft(4)} KB  ->  '
      '${(sw.elapsedMicroseconds / runs / 1000).toStringAsFixed(2)} ms/run',
    );
  }
}