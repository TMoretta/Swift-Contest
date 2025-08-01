import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

@RoutePage()
class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  late String profileId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profileId = context.read<AuthBloc>().state.profile!.id!;
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.blocStatus.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Inbox',
            actions: [
              (state.messages != null && state.messages!.isNotEmpty)
                  ? TextButton(
                      onPressed: () {
                        _showDeleteAllMessagesDialog(context: context, profileId: profileId);
                      },
                      child: Text('Delete all'),
                    )
                  : VoidWidget(),
            ],
          ),
          body: Builder(
            builder: (context) {
              switch (state.blocStatus) {
                case BlocStatus.initial:
                  return VoidWidget();
                case BlocStatus.loading:
                  if (!state.isInitialized) {
                    return VoidWidget();
                  } else {
                    continue successCase;
                  }
                case BlocStatus.failure:
                  if (!state.isInitialized) {
                    return RefreshIndicator.adaptive(
                      onRefresh: () async => context.read<AuthBloc>().add(AuthFetch()),
                      child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                    );
                  } else {
                    continue successCase;
                  }
                successCase:
                case BlocStatus.success:
                  return RefreshIndicator.adaptive(
                    onRefresh: () async => context.read<AuthBloc>().add(AuthFetch()),
                    child: (state.messages!.isEmpty)
                        ? ListViewWithCentralLabel(label: 'No message')
                        : ListView.builder(
                            itemCount: state.messages!.length,
                            itemBuilder: (context, index) {
                              final message = state.messages![index];
                              return ListTile(
                                onTap: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(message.title),
                                        content: Text(
                                            '${message.body}\n\n${DateFormat('dd/MM/yyyy, HH:mm').format(message.createdAt!)}'),
                                      );
                                    },
                                  );
                                  if (context.mounted && !message.isRead) {
                                    context
                                        .read<AuthBloc>()
                                        .add(AuthMarkMessageAsRead(messageId: message.id!));
                                  }
                                },
                                title: Text(message.title),
                                subtitle: Text('${message.body}\n'
                                    '${DateFormat('dd/MM/yyyy, HH:mm').format(message.createdAt!)}'),
                                tileColor: (!message.isRead)
                                    ? Theme.of(context).colorScheme.primaryContainer
                                    : Theme.of(context).colorScheme.surfaceContainer,
                                trailing: IconButton(
                                    onPressed: () async {
                                      final bool? res = await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Delete message'),
                                            content: Text(
                                                'Are you sure you want to delete this message?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () => context.router.pop(),
                                                  child: Text('Cancel')),
                                              TextButton(
                                                  onPressed: () => context.router.pop(true),
                                                  child: Text('Proceed')),
                                            ],
                                          );
                                        },
                                      );
                                      if (res == true) {
                                        if (context.mounted) {
                                          context
                                              .read<AuthBloc>()
                                              .add(AuthDeleteMessage(messageId: message.id!));
                                        }
                                      }
                                    },
                                    icon: Icon(Icons.delete)),
                              );
                            },
                          ),
                  );
              }
            },
          ),
        );
      },
    );
  }
}

void _showDeleteAllMessagesDialog({required BuildContext context, required String profileId}) {
  final authBloc = context.read<AuthBloc>();

  showDialog(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: authBloc,
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.blocStatus.isSuccess && state.sourceEvent is AuthDeleteAllMessages) {
              context.router.pop();
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text('Delete all messages'),
              content: Text('Are you sure you want to delete all messages?'),
              actions: [
                TextButton(
                  onPressed: () => context.router.pop(),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    authBloc.add(AuthDeleteAllMessages());
                  },
                  child: Text('Proceed'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
