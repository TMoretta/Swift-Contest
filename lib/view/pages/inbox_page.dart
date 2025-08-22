import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/inbox_bloc/inbox_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<InboxBloc>().add(InboxGetStream());
  }
  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InboxBloc, InboxState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isLoading) {
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
                        _showDeleteAllMessagesDialog(context);
                      },
                      child: Text('Delete all'),
                    )
                  : VoidWidget(),
            ],
          ),
          body: Builder(
            builder: (context) {
              if (state.status.isFailure && state.sourceEvent is InboxGetStream) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('An error occurred'),
                      FilledButton(
                        onPressed: () async => context.read<InboxBloc>().add(InboxGetStream()),
                        child: Text('Refresh'),
                      ),
                    ],
                  ),
                );
              }
              if (!state.isInitialized) {
                return VoidWidget();
              }
              return (state.messages!.isEmpty)
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
                                  .read<InboxBloc>()
                                  .add(InboxMarkMessageAsRead(messageId: message.id!));
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
                                      content:
                                          Text('Are you sure you want to delete this message?'),
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
                                if (!context.mounted) return;
                                if (res == true) {
                                  context
                                      .read<InboxBloc>()
                                      .add(InboxDeleteMessage(messageId: message.id!));
                                }
                              },
                              icon: Icon(Icons.delete)),
                        );
                      },
                    );
            },
          ),
        );
      },
    );
  }
}

void _showDeleteAllMessagesDialog(BuildContext context) {
  final inboxBloc = context.read<InboxBloc>();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: inboxBloc,
        child: BlocConsumer<InboxBloc, InboxState>(
          listener: (context, state) {
            if (state.status.isSuccess && state.sourceEvent is InboxDeleteAllMessages) {
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
                  onPressed: () => context.read<InboxBloc>().add(InboxDeleteAllMessages()),
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
