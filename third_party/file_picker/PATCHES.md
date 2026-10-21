# Local file_picker 8.3.7 patch

Runtime sources and LICENSE are copied from the published file_picker 8.3.7
package. The app depends on this directory directly; do not edit the pub cache.

The release R8 mapping resolves Play Console's `W2.b.j` to
`FileUtils.compressImage`. This copy fixes that method by reading bounds first,
reopening the content stream, and decoding with a power-of-two `inSampleSize`
that limits both dimensions to 4096 pixels. Ordinary images stay at their original
dimensions. Decoded bitmaps and streams are released after compression, and
failed output files are removed.

Upstream reference: https://github.com/vicajilau/flutter_file_picker/pull/2083
The upstream major upgrade also changes the Dart API and minimum iOS version;
this backport retains the app's existing API and iOS 13 support.

Regression test (from the repository root, with a JDK installed):

```sh
python3 tool/test_bitmap_sampling.py
```

Remove this copy when upgrading to an upstream release containing the fix,
after migrating callers and reviewing platform minimum versions.
