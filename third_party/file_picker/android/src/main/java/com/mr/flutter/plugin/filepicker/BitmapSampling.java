package com.mr.flutter.plugin.filepicker;

final class BitmapSampling {
    private BitmapSampling() {}

    static int sampleSize(int width, int height, int maxDimension) {
        if (width <= 0 || height <= 0 || maxDimension <= 0) {
            throw new IllegalArgumentException("Image dimensions must be positive");
        }
        int sample = 1;
        // Use ceiling division so odd dimensions also stay within the limit.
        while ((width - 1) / sample + 1 > maxDimension
                || (height - 1) / sample + 1 > maxDimension) {
            if (sample > Integer.MAX_VALUE / 2) return Integer.MAX_VALUE;
            sample *= 2;
        }
        return sample;
    }
}
