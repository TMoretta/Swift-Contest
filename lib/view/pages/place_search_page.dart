import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/db/entities/place.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';
import 'package:swift_contest/utils/functions/now.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_search_bar.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/place_search_page_bloc/place_search_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

@RoutePage()
class PlaceSearchPage extends StatefulWidget implements AutoRouteWrapper {
  const PlaceSearchPage({super.key});

  @override
  State<PlaceSearchPage> createState() => _PlaceSearchPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<PlaceSearchPageBloc>(
      create: (context) => PlaceSearchPageBloc(
        googlePlaceRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlaceSearchPageBloc, PlaceSearchPageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isLoading) {
          context.showLoader();
        }
        if (!state.status.isLoading) {
          context.hideLoader();
        }
        if (state.status.isSuccess && state.sourceEvent is PlaceSearchPageFetchPlace) {
          final googlePlace = state.googlePlace!;
          final Place place =
              Place(id: genUuid(), createdAt: now(), address: googlePlace.address, lat: googlePlace.lat, lon: googlePlace.lon);
          context.router.pop(place);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(title: 'Search place'),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(height: 16),
                  CustomSearchBar(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (value) {
                      context
                          .read<PlaceSearchPageBloc>()
                          .add(PlaceSearchPageSearchPlaceSuggestions(query: value));
                    },
                  ),
                  Builder(
                    builder: (context) {
                      if (state.googlePlaceSuggestions == null ||
                          state.googlePlaceSuggestions!.isEmpty) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              'No result',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        );
                      } else {
                        final suggestions = state.googlePlaceSuggestions!;
                        return Expanded(
                          child: ListView.builder(
                            itemCount: suggestions.length,
                            itemBuilder: (context, index) {
                              final suggestion = suggestions[index];
                              return ListTile(
                                title: Text(suggestion.address),
                                onTap: () {
                                  context
                                      .read<PlaceSearchPageBloc>()
                                      .add(PlaceSearchPageFetchPlace(id: suggestion.placeId));
                                },
                                trailing: IconButton(
                                  onPressed: () {
                                    _searchController.text = suggestion.address;
                                  },
                                  icon: Icon(Icons.north_west_rounded),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
