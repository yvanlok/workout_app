import 'package:flutter/material.dart';

typedef SearchFilter<T> = List<String?> Function(T t);
typedef ResultBuilder<T> = Widget Function(T t);
typedef SortCallback<T> = int Function(T a, T b);

/// This class helps to implement a search view, using [SearchDelegate].
/// It can show suggestion & unsuccessful-search widgets.
class SearchPage<T> extends SearchDelegate<T?> {
  /// Set this to true to display the complete list instead of the [suggestion].
  /// This is useful to give your users the chance to explore all the items in
  /// the list without knowing what so search for.
  final bool showItemsOnEmpty;

  /// Widget that is built when current query is empty.
  /// Suggests the user what's possible to do.
  final Widget suggestion;

  /// Widget built when there's no item in [items] that
  /// matches current query.
  final Widget failure;

  /// Method that builds a widget for each item that matches
  /// the current query parameter entered by the user.
  ///
  /// If no builder is provided by the user, the package will try
  /// to display a [ListTile] for each child, with a string
  /// representation of itself as the title.
  final ResultBuilder<T> builder;

  /// Method that returns the specific parameters intrinsic
  /// to a [T] instance.
  ///
  /// For example, filter a person by its name & age parameters:
  /// filter: (person) => [
  ///   person.name,
  ///   person.age.toString(),
  /// ]
  ///
  /// Al parameters to filter through must be [String] instances.
  final SearchFilter<T> filter;

  /// This text will be shown in the [AppBar] when
  /// current query is empty.
  final String? searchLabel;

  /// List of items where the search is going to take place on.
  /// They have [T] on run time.
  final List<T> items;

  /// Theme that would be used in the [AppBar] widget, inside
  /// the search view.
  final ThemeData? barTheme;

  /// Provided queries only matches with the begining of each
  /// string item's representation.
  final bool itemStartsWith;

  /// Provided queries only matches with the end of each
  /// string item's representation.
  final bool itemEndsWith;

  /// Functions that gets called when the screen performs a search operation.
  final ValueChanged<String>? onQueryUpdate;

  /// The style of the [searchFieldLabel] text widget.
  final TextStyle? searchStyle;

  final SortCallback<T>? sort;

  SearchPage({
    this.suggestion = const SizedBox(),
    this.failure = const SizedBox(),
    required this.builder,
    required this.filter,
    required this.items,
    this.showItemsOnEmpty = false,
    this.searchLabel,
    this.barTheme,
    this.itemStartsWith = false,
    this.itemEndsWith = false,
    this.onQueryUpdate,
    this.searchStyle,
    this.sort,
  }) : super(
          searchFieldLabel: searchLabel,
          searchFieldStyle: searchStyle,
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return barTheme ??
        Theme.of(context).copyWith(
          inputDecorationTheme: const InputDecorationTheme(
            focusedErrorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            border: InputBorder.none,
          ),
        );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    // Builds a 'clear' button at the end of the [AppBar]
    return [
      AnimatedOpacity(
        opacity: query.isNotEmpty ? 1.0 : 0.0,
        duration: kThemeAnimationDuration,
        curve: Curves.easeInOutCubic,
        child: IconButton(
          tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Creates a default back button as the leading widget.
    // It's aware of targeted platform.
    // Used to close the view.
    return BackButton(
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  bool _filterByValue({
    required String query,
    required String? value,
  }) {
    if (value == null) {
      return false;
    }
    final queryTokens = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty);
    final valueTokens = value
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty);

    return queryTokens.any((queryToken) =>
        valueTokens.any((valueToken) => valueToken.contains(queryToken)));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Call 'onQueryUpdate' at the start of the operation
    onQueryUpdate?.call(query);

    // Clean the query: trim whitespace and convert to lowercase
    final cleanQuery = query.toLowerCase().trim();

    // Filter items based on the query
    final filteredItems = items.where(
      (item) {
        final filteredValues =
            filter(item).map((value) => value?.toLowerCase().trim() ?? '');
        return filteredValues.any(
          (value) => _filterByValue(query: cleanQuery, value: value),
        );
      },
    ).toList();

    // Calculate relevance scores and sort items based on these scores
    final scoredItems = filteredItems.map((item) {
      final itemValue = filter(item).firstWhere(
        (value) => value != null,
        orElse: () =>
            '', // Default to an empty string if no non-null values are found
      );
      return {
        'item': item,
        'score':
            _calculateRelevanceScore(query: cleanQuery, value: itemValue ?? ''),
      };
    }).toList();

    // Sort by score in descending order
    scoredItems.sort((a, b) {
      final scoreA = a['score'] as int? ?? 0;
      final scoreB = b['score'] as int? ?? 0;
      return scoreB.compareTo(scoreA);
    });

    // Build a list with all filtered items if query and result list are not empty
    return cleanQuery.isEmpty && !showItemsOnEmpty
        ? suggestion
        : scoredItems.isEmpty
            ? failure
            : ListView(
                children: scoredItems
                    .map((entry) => builder(entry['item'] as T))
                    .toList(),
              );
  }
}

int _calculateRelevanceScore({
  required String query,
  required String value,
}) {
  final queryTokens = query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((token) => token.isNotEmpty)
      .toList(); // Ensure this list is non-null

  final valueTokens = value
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((token) => token.isNotEmpty)
      .toList(); // Ensure this list is non-null

  // Base score for each match
  int score = 0;

  for (var queryToken in queryTokens) {
    if (valueTokens.contains(queryToken)) {
      // Increase score based on the number of matches
      score +=
          valueTokens.where((token) => token.contains(queryToken)).length * 10;
    }
  }

  return score;
}
