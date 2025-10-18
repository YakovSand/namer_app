import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var all = <WordPair>[];
  var favorites = <WordPair>[];
  MyAppState() {
    all.add(current);
  }

  void getNext() {
    current = WordPair.random();
    all.add(current);
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // Scaffold with NavigationRail to switch between pages and Expanded page area
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                // Update the state when a new destination is selected
                setState(() {
                  selectedIndex = value;
                });
                print('selected: $value');
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

// GeneratorPage with scrollable list of generated word pairs
class GeneratorPage extends StatefulWidget {
  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final ScrollController _scrollController = ScrollController();
  int _lastCount = 0;
  MyAppState? _appState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _appState = context.read<MyAppState>();
      _lastCount = _appState?.all.length ?? 0;
      _appState?.addListener(_onAppStateChanged);
      _scrollToBottom();
    });
  }

  void _onAppStateChanged() {
    final cur = _appState?.all.length ?? 0;
    if (cur > _lastCount) {
      _lastCount = cur;
      _scrollToBottom();
    } else {
      _lastCount = cur;
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Size getResponsiveButtonSize(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    // Tune ratios as needed
    final widthRatio = isLandscape ? 0.35 : 0.45;
    final heightRatio = isLandscape ? 0.10 : 0.07;

    final buttonWidth = screenSize.width * widthRatio;
    final buttonHeight = screenSize.height * heightRatio;

    return Size(buttonWidth, buttonHeight);
  }

  @override
  void dispose() {
    _appState?.removeListener(_onAppStateChanged);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    var theme = Theme.of(context);
    // Screen size aware sizes
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    // compute responsive values and clamp them to reasonable limits
    final double fontSize = (screenWidth * 0.045).clamp(14.0, 40.0);
    final double horizontalPadding = (screenWidth * 0.04).clamp(8.0, 48.0);
    final double verticalPadding = (screenHeight * 0.018).clamp(6.0, 20.0);
    final double itemVerticalPadding = (screenHeight * 0.006).clamp(4.0, 12.0);
    final double iconSizeInList = (screenWidth * 0.03).clamp(16.0, 28.0);
    final double itemFontSizeInList = (screenWidth * 0.045).clamp(14.0, 32.0);
    final double iconTextSpacingInList = (screenWidth * 0.01).clamp(6.0, 12.0);
    // compute responsive button size
    Size buttonSize = getResponsiveButtonSize(context);

    final ButtonStyle mainButtonStyle = ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      textStyle: TextStyle(fontSize: fontSize),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        // final availableWidth = constraints.maxWidth;

        // compute sizes relative to available space (will adapt to orientation)
        final double listHeight = (availableHeight * 0.32).clamp(60.0, 300.0);
        final double gap = (availableHeight * 0.02).clamp(8.0, 24.0);
        final double likeIconSizeInButton = (screenWidth * 0.06).clamp(
          18.0,
          48.0,
        );
        final double likeLabelFontSizeInButton = (screenWidth * 0.05).clamp(
          14.0,
          40.0,
        );

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewPadding.bottom + 24.0,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: availableHeight),
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              bottom: true,
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    SizedBox(height: gap * 5),
                    // scrollable centered list
                    SizedBox(
                      height: listHeight,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(
                              vertical: itemVerticalPadding,
                            ),
                            itemCount: appState.all.length,
                            itemBuilder: (context, index) {
                              var generatedPair = appState.all[index];
                              var isFavorite = appState.favorites.contains(
                                generatedPair,
                              );
                              final isLatest =
                                  index == (appState.all.length - 1);
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: itemVerticalPadding,
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (isFavorite) ...[
                                        Icon(
                                          Icons.favorite,
                                          color: theme.colorScheme.primary,
                                          size: iconSizeInList,
                                        ),
                                        SizedBox(width: iconTextSpacingInList),
                                      ],
                                      Text(
                                        generatedPair.asLowerCase,
                                        style: TextStyle(
                                          fontSize: itemFontSizeInList,
                                          fontFamily: 'Roboto',
                                          fontWeight: isLatest
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          color:
                                              theme.textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          // top fade overlay
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Container(
                                height: (listHeight * 0.3).clamp(20.0, 60.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer
                                      // ignore: deprecated_member_use
                                      .withOpacity(1.0),
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer
                                      // ignore: deprecated_member_use
                                      .withOpacity(0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: gap),

                    // BigCard expands but won't overflow due to the outer SingleChildScrollView
                    Flexible(
                      fit: FlexFit.loose,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: BigCard(pair: pair),
                      ),
                    ),

                    SizedBox(height: gap),

                    // Buttons: use Wrap so they wrap on narrow heights (landscape)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: gap,
                        runSpacing: gap / 2,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: buttonSize.width * 0.8,
                              maxWidth: buttonSize.width,
                              minHeight: buttonSize.height * 0.8,
                              maxHeight: buttonSize.height,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                appState.getNext();
                              },
                              style: mainButtonStyle,
                              child: Text('Next'),
                            ),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: buttonSize.width * 0.8,
                              maxWidth: buttonSize.width,
                              minHeight: buttonSize.height * 0.8,
                              maxHeight: buttonSize.height,
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                appState.toggleFavorite();
                              },
                              style: mainButtonStyle,
                              icon: Icon(
                                appState.favorites.contains(pair)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: theme.colorScheme.primary,
                                size: likeIconSizeInButton,
                              ),
                              label: Text(
                                'Like',
                                style: TextStyle(
                                  fontSize: likeLabelFontSizeInButton,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: gap),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final favorites = appState.favorites;
    final theme = Theme.of(context);

    if (favorites.isEmpty) {
      return Center(child: Text('No favorites yet.'));
    }

    // Screen / orientation aware sizes
    final media = MediaQuery.of(context);
    final screenW = media.size.width;
    final screenH = media.size.height;
    final isPortrait = media.orientation == Orientation.portrait;

    // Grid columns: 2 in portrait, 3 in landscape (adjust as needed)
    final int crossAxisCount = isPortrait ? 2 : 3;

    // Spacing & tile sizing derived from screen dimensions
    final double spacing = (screenW * 0.03).clamp(8.0, 24.0);
    final double tileHeight = (screenH * 0.11).clamp(56.0, 160.0);
    final double tileWidth =
        (screenW - (spacing * (crossAxisCount + 1))) / crossAxisCount;
    final double childAspectRatio = tileWidth / tileHeight;

    // Font / icon sizes derived from tile size
    final double titleFontSize = (tileHeight * 0.36).clamp(12.0, 28.0);
    final double iconSize = (tileHeight * 0.34).clamp(14.0, 36.0);

    final double headerFontSize = (screenW * 0.05).clamp(14.0, 28.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(spacing),
          child: Text(
            'You have ${favorites.length} favorites:',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: headerFontSize,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing),
            child: GridView.builder(
              itemCount: favorites.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: childAspectRatio,
              ),
              itemBuilder: (context, index) {
                final pair = favorites[index];
                return Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: spacing * 0.5),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            pair.asLowerCase,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontFamily: 'Roboto',
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        SizedBox(width: spacing * 0.25),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          icon: Icon(Icons.delete, size: iconSize),
                          onPressed: () => appState.removeFavorite(pair),
                          tooltip: 'Remove',
                          splashRadius: (iconSize * 0.9).clamp(18.0, 28.0),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair});

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    // Screen / orientation aware sizes
    final media = MediaQuery.of(context);
    final screenW = media.size.width;
    final screenH = media.size.height;
    final isPortrait = media.orientation == Orientation.portrait;
    final cardElevation = 25.0;
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
      fontSize: isPortrait
          ? (screenW * 0.1).clamp(24.0, 64.0)
          : (screenH * 0.15).clamp(24.0, 64.0),
    );

    return Card(
      color: theme.colorScheme.primary,
      elevation: cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: pair.first,
                style: style.copyWith(fontWeight: FontWeight.w100),
              ),
              TextSpan(
                text: pair.second,
                style: style.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
