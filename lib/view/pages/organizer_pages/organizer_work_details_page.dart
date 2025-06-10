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
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            //* Title
            Text(
              work.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
            SizedBox(height: 8),
            //* Description
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text(work.description, style: TextStyle(fontSize: 18)),
              ],
            ),
            SizedBox(height: 8),
            //* Organizer name
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Icon(
                  Icons.person_rounded,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Expanded(
                  child: Text(
                    participant.fullName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
