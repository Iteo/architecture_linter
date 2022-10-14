class LayerRule {
  const LayerRule({
    required this.bannedLayers,
    required this.layer,
  });

  final String layer;
  final List<String> bannedLayers;
}
