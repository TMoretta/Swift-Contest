import 'package:flutter/material.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';

class OrganizerWorkDetailsPage extends StatefulWidget {
  final ParticipationBundle participationBundle;

  const OrganizerWorkDetailsPage({required this.participationBundle, super.key});

  @override
  State<OrganizerWorkDetailsPage> createState() => _OrganizerWorkDetailsPageState();
}

class _OrganizerWorkDetailsPageState extends State<OrganizerWorkDetailsPage> {
  late ParticipationBundle participationBundle;

  @override
  void initState() {
    super.initState();
    participationBundle = widget.participationBundle;
  }

  @override
  Widget build(BuildContext context) {
    final work = participationBundle.work!;
    final participant = participationBundle.participant;
    return Scaffold(
      appBar: CustomAppBar(title: 'Work'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 16),
              //* Title
              Text(
                work.name,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              SizedBox(height: 8),
              //* Images carousel
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: work.imagesUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: (work.imagesUrls.isNotEmpty)
                          ? Image.network(
                              work.imagesUrls[index],
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/image_not_found.jpg',
                                  fit: BoxFit.cover,
                                );
                              },
                              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                if (wasSynchronouslyLoaded || frame != null) {
                                  return child;
                                }
                                return const Loader();
                              },
                            )
                          : Image.asset('assets/images/image_not_found.jpg', fit: BoxFit.cover),
                    );
                  },
                ),
              ),
              SizedBox(height: 12),
              //* Description
              Text(
                'Description',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
              Text(work.description),
              SizedBox(height: 16),
              //* Participant name
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.person_rounded,
                    size: 24,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      participant.fullName,
                      // style: Theme.of(context)
                      //     .textTheme
                      //     .titleMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
