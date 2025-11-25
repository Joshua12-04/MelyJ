import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../bloc/player_load_event.dart';
import '../bloc/player_load_states.dart';
import '../bloc/player_state.dart';
import '../bloc/playerbloc.dart';
import '../model/audio_item.dart';

class Swiper extends StatefulWidget {
  final PageController pageController;
  final List<AudioItem> audioList;
  final Color color;
  final PlayerBloc bloc;

  const Swiper({
    Key? key,
    required this.pageController,
    required this.audioList,
    required this.color,
    required this.bloc,
  }) : super(key: key);

  @override
  State<Swiper> createState() => _SwiperState();
}

class _SwiperState extends State<Swiper> {
  bool _isManuallyChanging = false;

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(() {
      if (widget.pageController.position.isScrollingNotifier.value) {
        _isManuallyChanging = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayState>(
      builder: (context, state) {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * .35,
              child: PageView.builder(
                controller: widget.pageController,
                itemCount: widget.audioList.length,
                onPageChanged: (indice) {
                  final actual = widget.bloc.state;
                  if (_isManuallyChanging &&
                      actual is PlayingState &&
                      indice != actual.currentIndex) {
                    widget.bloc.add(PlayerLoadEvent(indice));
                  }
                  _isManuallyChanging = false;
                },
                itemBuilder: (context, index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      widget.audioList[index].imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SmoothPageIndicator(
              controller: widget.pageController,
              count: widget.audioList.length,
              effect: SlideEffect(
                spacing: 8,
                radius: 10,
                dotWidth: 17,
                dotHeight: 17,
                paintStyle: PaintingStyle.stroke,
                strokeWidth: 1.5,
                dotColor: const Color.fromRGBO(180, 140, 100, 100),
                activeDotColor: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }
}