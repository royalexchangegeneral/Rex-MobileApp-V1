"""Compile and exercise the actual Android sampling helper with a JDK."""
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "third_party/file_picker/android/src/main/java/com/mr/flutter/plugin/filepicker/BitmapSampling.java"

TEST = """
package com.mr.flutter.plugin.filepicker;
public class BitmapSamplingTest {
    public static void main(String[] args) {
        int[][] cases = {
            {4000, 3000, 1}, {4096, 4096, 1}, {4097, 3000, 2},
            {8000, 6000, 2}, {6000, 8000, 2}, {12000, 9000, 4},
            {1, 20000, 8}, {8193, 4096, 4}, {1, 1, 1},
            {Integer.MAX_VALUE, Integer.MAX_VALUE, 524288}
        };
        for (int[] c : cases) {
            int sample = BitmapSampling.sampleSize(c[0], c[1], 4096);
            if (sample != c[2]) throw new AssertionError("Unexpected sample: " + sample);
            if ((c[0] - 1) / sample + 1 > 4096 || (c[1] - 1) / sample + 1 > 4096)
                throw new AssertionError("Decoded image exceeds limit");
        }
        for (int[] c : new int[][] {{0, 10, 4096}, {10, -1, 4096}, {10, 10, 0}}) {
            try {
                BitmapSampling.sampleSize(c[0], c[1], c[2]);
                throw new AssertionError("Invalid dimensions accepted");
            } catch (IllegalArgumentException expected) {}
        }
        System.out.println("Passed 13 bitmap sampling cases");
    }
}
"""

with tempfile.TemporaryDirectory(prefix="rex-bitmap-test-") as temp:
    test_file = Path(temp) / "BitmapSamplingTest.java"
    test_file.write_text(TEST)
    subprocess.run(["javac", "-d", temp, str(SOURCE), str(test_file)], check=True)
    subprocess.run(["java", "-cp", temp, "com.mr.flutter.plugin.filepicker.BitmapSamplingTest"], check=True)
