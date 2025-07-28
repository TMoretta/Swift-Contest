import 'package:flutter/material.dart';
import 'package:swift_contest/view/widgets/loader.dart';

class VotingProcedureWorkDetailsView extends StatelessWidget {
  final String participantFullName;
  final String workName;
  final String workDescription;
  final List<String> workImagesUrls;

  const VotingProcedureWorkDetailsView({
    super.key,
    required this.participantFullName,
    required this.workName,
    required this.workDescription,
    required this.workImagesUrls,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //* Title
        Text(
          workName,
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
            itemCount: workImagesUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: (workImagesUrls.isNotEmpty)
                    ? Image.network(
                        workImagesUrls[index],
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
        Text(
          'Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        Text(workDescription, style: TextStyle(fontSize: 18)),
        SizedBox(height: 8),
        //* Participant name
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
                participantFullName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
