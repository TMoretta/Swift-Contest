import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  late Profile profile;

  @override
  void initState() {
    super.initState();
    profile = context.read<AuthBloc>().state.profile!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Inbox'),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            switch (state.blocStatus) {
              case BlocStatus.initial:
                return SizedBox.shrink();
              case BlocStatus.loading:
                return Loader();
              case BlocStatus.failure:
              case BlocStatus.success:
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return RefreshIndicator.adaptive(
                      onRefresh: () async =>
                          context.read<AuthBloc>().add(AuthFetchProfileMessages()),
                      child: (state.messages!.isEmpty)
                          ? ListView(
                              children: [
                                SizedBox(
                                  height: constraints.maxHeight,
                                  child: Center(
                                    child: Text('No message yet'),
                                  ),
                                ),
                              ],
                            )
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
                                              '${message.body}\n\n${DateFormat('dd/MM/yyyy, HH:mm').format(message.createdAt)}'),
                                        );
                                      },
                                    );
                                    if (context.mounted && !message.isRead) {
                                      context
                                          .read<AuthBloc>()
                                          .add(AuthMarkMessageAsRead(messageId: message.id));
                                    }
                                  },
                                  title: Text(message.title),
                                  subtitle: Text('${message.body}\n'
                                      '${DateFormat('dd/MM/yyyy, HH:mm').format(message.createdAt)}'),
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
                                                    onPressed: () {
                                                      context.pop();
                                                    },
                                                    child: Text('Cancel')),
                                                TextButton(
                                                    onPressed: () {
                                                      context.pop(true);
                                                    },
                                                    child: Text('Proceed')),
                                              ],
                                            );
                                          },
                                        );
                                        if (res == true) {
                                          if (context.mounted) {
                                            context
                                                .read<AuthBloc>()
                                                .add(AuthDeleteMessage(messageId: message.id));
                                          }
                                        }
                                      },
                                      icon: Icon(Icons.delete)),
                                );
                              },
                            ),
                    );
                  },
                );
            }
          },
        ),
      ),
    );
  }
}
