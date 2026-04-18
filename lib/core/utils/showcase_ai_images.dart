String showcaseAiImage(
  String prompt, {
  int width = 1200,
  int height = 900,
  int seed = 1,
}) {
  final encodedPrompt = Uri.encodeComponent(prompt);
  return 'https://image.pollinations.ai/prompt/$encodedPrompt?width=$width&height=$height&seed=$seed&nologo=true&enhance=true';
}
