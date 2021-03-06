/// Remaps [value] within the range [min]-[max] to the output range
/// [outMin] - [outMax]
double lerpDouble(num value, num min, num max, double outMin, double outMax) {
  assert(min < max);
  assert(outMin < outMax);

  if (value <= min) return outMin;
  if (value >= max) return outMax;

  var t = (value - min) / (max - min);
  return outMin + t * (outMax - outMin);
}

/// Produces a pseudo-random 32-bit unsigned integere for the point at [x, y]
/// using [seed].
///
/// This can be used to associate random values with tiles without having to
/// store them.
int hashPoint(int x, int y, [int? seed]) {
  seed ??= 0;

  // From: https://stackoverflow.com/a/12996028/9457
  int hashInt(int n) {
    n = (((n >> 16) ^ n) * 0x45d9f3b) & 0xffffffff;
    n = (((n >> 16) ^ n) * 0x45d9f3b) & 0xffffffff;
    n = (n >> 16) ^ n;
    return n;
  }

  return hashInt(hashInt(hashInt(seed) + x) + y) & 0xffffffff;
}
