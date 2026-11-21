import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/providers/common/photo_min_scale_provider.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/motion.dart';
import 'package:flutter_nga/utils/picture_utils.dart' as picture_utils;

class PhotoPreviewPage extends HookConsumerWidget {
  const PhotoPreviewPage({super.key, this.url, this.screenWidth});

  final String? url;
  final double? screenWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minScale = ref.watch(photoMinScaleProvider);
    final showChrome = useState(true);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    useEffect(() {
      Future.microtask(() {
        ref.read(photoMinScaleProvider.notifier).load(url!, screenWidth);
      });
      return null;
    }, [url]);

    final topPadding = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
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
            if (minScale == 0)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            else
              PhotoView(
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                imageProvider: CachedNetworkImageProvider(
                  picture_utils.getOriginalUrl(url!),
                ),
                minScale: minScale,
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
                  duration: disableAnimations
                      ? Duration.zero
                      : Motion.durationShort4,
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
                      padding: EdgeInsets.only(top: topPadding),
                      child: SizedBox(
                        height: kToolbarHeight,
                        child: Row(
                          children: [
                            const BackButton(color: Colors.white),
                            const Expanded(
                              child: Text(
                                '查看图片',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.download_outlined,
                                color: Colors.white,
                              ),
                              onPressed: _save,
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
    );
  }

  Future<void> _save() async {
    try {
      await Data().resourceRepository.saveImageToGallery(
        picture_utils.getOriginalUrl(url!),
      );
      AppToast.success("保存到相册成功");
    } catch (e) {
      AppToast.error(e);
    }
  }
}
