import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import '../bloc/player_load_states.dart';
import '../bloc/playerbloc.dart';
import '../bloc/player_load_event.dart';
import '../bloc/player_state.dart';
import '../model/audio_item.dart';

class MusicPlayerWithDrawer extends StatefulWidget {
  final List<AudioItem> canciones;
  final Widget mainScreen;
  final VoidCallback onSettingsTap;

  const MusicPlayerWithDrawer({
    Key? key,
    required this.canciones,
    required this.mainScreen,
    required this.onSettingsTap,
  }) : super(key: key);

  @override
  State<MusicPlayerWithDrawer> createState() => MusicPlayerWithDrawerState();
}

class MusicPlayerWithDrawerState extends State<MusicPlayerWithDrawer> {
  final GlobalKey<SliderDrawerState> _sliderDrawerKey =
  GlobalKey<SliderDrawerState>();

  void openDrawer() {
    _sliderDrawerKey.currentState?.openSlider();
  }

  void closeDrawer() {
    _sliderDrawerKey.currentState?.closeSlider();
  }

  void toggleDrawer() {
    if (_sliderDrawerKey.currentState?.isDrawerOpen ?? false) {
      closeDrawer();
    } else {
      openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliderDrawer(
      key: _sliderDrawerKey,
      appBar: SliderAppBar(
        config: SliderAppBarConfig(
          drawerIconColor: Colors.black,
          backgroundColor: Color(0xffffe082),
          drawerIconSize: 40,
          title: const Text(
            'MelyJ',
            style: TextStyle(
              fontSize: 24,
              fontFamily: "DMSerif",
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              closeDrawer();
              widget.onSettingsTap();
            },
          ),
        ),
      ),
      slideDirection: SlideDirection.leftToRight,
      sliderOpenSize: 260,
      slider: _DrawerContent(
        canciones: widget.canciones,
        onSettingsTap: () {
          closeDrawer();
          widget.onSettingsTap();
        },
      ),
      child: widget.mainScreen,
    );
  }
}

class _DrawerContent extends StatefulWidget {
  final List<AudioItem> canciones;
  final VoidCallback onSettingsTap;

  const _DrawerContent({required this.canciones, required this.onSettingsTap});

  @override
  State<_DrawerContent> createState() => _DrawerContentState();
}

class _DrawerContentState extends State<_DrawerContent> {
  late PageController _pageController;
  bool _isManualChange = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<PlayerBloc>();
    final initialIndex = bloc.state is PlayingState
        ? (bloc.state as PlayingState).currentIndex
        : 0;
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    _isManualChange = true;
    final bloc = context.read<PlayerBloc>();
    final currentState = bloc.state;

    if (currentState is PlayingState && index != currentState.currentIndex) {
      bloc.add(PlayerLoadEvent(index));
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _isManualChange = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFE082),
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(),
            // Divider eliminado o con altura 0
            const SizedBox(height: 0), // Reemplaza el Divider
            _SettingsButton(onTap: widget.onSettingsTap),
            _DeleteDatabaseButton(),
            const Spacer(),
            _AlbumArtCarousel(
              canciones: widget.canciones,
              pageController: _pageController,
              onPageChanged: _onPageChanged,
              isManualChange: _isManualChange,
            ),
            _PlaybackControls(canciones: widget.canciones),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE7E23B),
            const Color(0xFFFFE082).withOpacity(0.8),
            const Color(0xFFE4EFB3),
          ],
        ),
        // Eliminar cualquier borde inferior si existe
        border: null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'MelyJ - Music',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: "DMSerif",
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unas hambuerguesitas o qué???',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87.withOpacity(0.7),
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SettingsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.settings, color: Color(0xff000000), size: 24),
      title: const Text(
        'Ajustes',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }
}

class _DeleteDatabaseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.delete_forever, color: Color(0xFFD32F2F), size: 24),
      title: const Text(
        'Borrar todas las canciones',
        style: TextStyle(
          color: Color(0xFFD32F2F),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () => _showDeleteConfirmation(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFFFF9E6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 28),
            SizedBox(width: 10),
            Text(
              '¿Confirmar?',
              style: TextStyle(
                fontFamily: "DMSerif",
                color: Colors.black,
              ),
            ),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que quieres borrar todas las canciones de la base de datos? Esta acción no se puede deshacer.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PlayerBloc>().add(DeleteAllAudioItems());
              Navigator.pop(dialogContext);

              // Mostrar mensaje de confirmación
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Todas las canciones han sido eliminadas'),
                  backgroundColor: Color(0xFFD32F2F),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Borrar todo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlbumArtCarousel extends StatelessWidget {
  final List<AudioItem> canciones;
  final PageController pageController;
  final Function(int) onPageChanged;
  final bool isManualChange;

  const _AlbumArtCarousel({
    required this.canciones,
    required this.pageController,
    required this.onPageChanged,
    required this.isManualChange,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerBloc, PlayState>(
      listener: (context, state) {
        if (state is PlayingState &&
            !isManualChange &&
            pageController.hasClients) {
          pageController.animateToPage(
            state.currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: SizedBox(
        height: 200,
        child: PageView.builder(
          controller: pageController,
          itemCount: canciones.length,
          onPageChanged: onPageChanged,
          itemBuilder: (context, index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(canciones[index].imagePath!, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  final List<AudioItem> canciones;

  const _PlaybackControls({required this.canciones});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayState>(
      builder: (context, state) {
        AudioItem? currentSong;
        bool isPlaying = false;

        if (state is PlayingState) {
          final index = state.currentIndex;
          if (index >= 0 && index < canciones.length) {
            currentSong = canciones[index];
            isPlaying = state.playing;
          }
        }

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFE082).withOpacity(0.3),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (currentSong != null) ...[
                _SongInfo(song: currentSong),
                const SizedBox(height: 16),
              ],
              _ControlButtons(isPlaying: isPlaying),
            ],
          ),
        );
      },
    );
  }
}

class _SongInfo extends StatelessWidget {
  final AudioItem song;

  const _SongInfo({required this.song});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xffffe082).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            song.title!,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            song.artist!,
            style: TextStyle(
              color: Colors.black.withOpacity(0.7),
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ControlButtons extends StatelessWidget {
  final bool isPlaying;

  const _ControlButtons({required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PlayerBloc>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ControlButton(
          icon: Icons.skip_previous,
          onPressed: () => bloc.add(PrevEvent()),
        ),
        _ControlButton(
          icon: isPlaying ? Icons.pause : Icons.play_arrow,
          onPressed: () => bloc.add(isPlaying ? PauseEvent() : PlayEvent()),
          isPrimary: true,
        ),
        _ControlButton(
          icon: Icons.skip_next,
          onPressed: () => bloc.add(NextEvent()),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: isPrimary ? 64 : 56,
        height: isPrimary ? 64 : 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPrimary
              ? const Color(0xfff6f6f6).withOpacity(0.2)
              : Colors.white.withOpacity(0.6),
          border: Border.all(
            color: isPrimary
                ? const Color(0xff000000).withOpacity(0.6)
                : Colors.black.withOpacity(0.4),
            width: isPrimary ? 2 : 1,
          ),
        ),
        child: Icon(
          icon,
          color: isPrimary ? const Color(0xFF000000) : Colors.black,
          size: isPrimary ? 32 : 28,
        ),
      ),
    );
  }
}