import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/motion.dart';
import 'package:flutter_nga/utils/picture_utils.dart' as picture_utils;

class PhotoPreviewPage extends HookConsumerWidget {
  const PhotoPreviewPage({super.key, this.url});

  final String? url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showChrome = useState(true);
    final saving = useState(false);
    final reloadTick = useState(0);
    final rawUrl = url?.trim() ?? '';
    final hasUrl = rawUrl.isNotEmpty;
    final originalUrl = hasUrl ? picture_utils.getOriginalUrl(rawUrl) : '';

    final mediaPadding = MediaQuery.paddingOf(context);
    final isApple = context.isAppleStyle;
    final isMacDesktop = context.isMacDesktopAppleStyle;
    final leftInset = mediaPadding.left + context.macTitlebarInset;
    final barHeight = isMacDesktop ? 52.0 : kToolbarHeight;

    Future<void> saveImage() async {
      if (!hasUrl || saving.value) return;
      saving.value = true;
      try {
        await Data().resourceRepository.saveImageToGallery(originalUrl);
        AppToast.success("保存到相册成功");
      } catch (e) {
        AppToast.error(e);
      } finally {
        if (context.mounted) {
          saving.value = false;
        }
      }
    }

    Widget buildErrorView({bool allowRetry = true}) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.resolve(context, Icons.broken_image_outlined),
                size: 40,
                color: Colors.white70,
              ),
              const SizedBox(height: 12),
              const Text(
                '图片加载失败',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              if (allowRetry) ...[
                const SizedBox(height: 12),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  onPressed: () => reloadTick.value++,
                  child: const Text('重试'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).maybePop(),
      },
      child: Focus(
        autofocus: true,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: Colors.black,
            extendBodyBehindAppBar: true,
            body: Stack(
              fit: StackFit.expand,
              children: [
                if (!hasUrl)
                  buildErrorView(allowRetry: false)
                else
                  PhotoView(
                    key: ValueKey('$originalUrl-${reloadTick.value}'),
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                    imageProvider: CachedNetworkImageProvider(originalUrl),
                    minScale: PhotoViewComputedScale.contained,
                    initialScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 4.0,
                    loadingBuilder: (_, _) => const Center(
                      child: AppActivityIndicator(color: Colors.white),
                    ),
                    errorBuilder: (_, _, _) => buildErrorView(),
                    onTapUp: (_, _, _) => showChrome.value = !showChrome.value,
                  ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    ignoring: !showChrome.value,
                    child: AnimatedOpacity(
                      opacity: showChrome.value ? 1.0 : 0.0,
                      duration: Motion.resolveDuration(
                        context,
                        Motion.durationShort4,
                      ),
                      curve: Motion.emphasized,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x99000000), Color(0x00000000)],
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            leftInset,
                            mediaPadding.top,
                            mediaPadding.right,
                            0,
                          ),
                          child: SizedBox(
                            height: barHeight,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    AppIcons.back(context),
                                    color: Colors.white,
                                    size: isMacDesktop ? 18 : 22,
                                  ),
                                  tooltip: '返回',
                                  onPressed: () =>
                                      Navigator.of(context).maybePop(),
                                ),
                                Expanded(
                                  child: Text(
                                    '查看图片',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isApple ? 16 : 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (hasUrl)
                                  IconButton(
                                    icon: saving.value
                                        ? const AppActivityIndicator(
                                            radius: 9,
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          )
                                        : Icon(
                                            AppIcons.download(context),
                                            color: Colors.white,
                                          ),
                                    onPressed: saving.value ? null : saveImage,
                                    tooltip: '保存图片',
                                  ),
                                const SizedBox(width: 4),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
