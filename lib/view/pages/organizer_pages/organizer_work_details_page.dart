import 'package:flutter/material.dart';
import 'package:swift_contest/model/mixed_models/participant_and_work.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';

class OrganizerWorkDetailsPage extends StatefulWidget {
  final Map<String, dynamic> participantAndWorkJson;

  const OrganizerWorkDetailsPage(
      {required this.participantAndWorkJson, super.key});

  @override
  State<OrganizerWorkDetailsPage> createState() =>
      _OrganizerWorkDetailsPageState();
}

class _OrganizerWorkDetailsPageState extends State<OrganizerWorkDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final participantAndWork =
        ParticipantAndWork.fromJson(widget.participantAndWorkJson);
    return Scaffold(
      appBar: CustomAppBar(title: 'Work'),
      body: SafeArea(child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: ListView(
                // mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.start,
                // spacing: 8,
                children: [
                  //* Title
                  Text(
                    participantAndWork.work.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  //* Images carousel
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: participantAndWork.work.imagesUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: (participantAndWork.work.imagesUrls.isNotEmpty) ? Image.network(
                            participantAndWork.work.imagesUrls[index],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/image_not_found.jpg',
                                fit: BoxFit.cover,
                              );
                            },
                            frameBuilder: (context, child, frame,
                                wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded || frame != null) {
                                return child;
                              }
                              return const Loader();
                            },
                          ) : Image.asset('assets/images/image_not_found.jpg', fit: BoxFit.cover),
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      Text(participantAndWork.work.description,
                          style: TextStyle(fontSize: 18)),
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
                          participantAndWork.participant.fullName,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      )),
    );
  }
}
