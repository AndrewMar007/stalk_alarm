import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stalc_alarm/view/bloc/alarm_history_bloc/alarm_history_bloc.dart';
import 'package:stalc_alarm/view/bloc/alarm_history_bloc/alarm_history_bloc_state.dart';
import 'package:stalc_alarm/view/widgets/gradient_vertical_divider.dart';
import 'package:stalc_alarm/view/widgets/radiation_loader.dart';

import '../../core/helper/date_fromatter.dart';
import '../bloc/alarm_history_bloc/alarm_history_bloc_event.dart';
import '../widgets/radiation_loader_text.dart';

class OblastDetailsPage extends StatefulWidget {
  final int id;
  final String title;

  const OblastDetailsPage({super.key, required this.id, required this.title});

  @override
  State<OblastDetailsPage> createState() => _OblastDetailsPageState();
}

const bottomGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color.fromARGB(72, 232, 136, 27),
    Color.fromARGB(4, 249, 189, 25),
    Color.fromARGB(4, 249, 189, 25),
    Color.fromARGB(66, 232, 136, 27),
  ],
  stops: [0.02, 0.4, 0.8, 1.0],
);

const verticalGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color.fromARGB(72, 232, 136, 27), Color.fromARGB(255, 20, 11, 2)],
  stops: [0.0, 1.0],
);

class _OblastDetailsPageState extends State<OblastDetailsPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<AlarmHistoryBloc>().add(
      GetAlarmHistoryBlocEvent(
        oblastId: widget.id,
        days: 3, // або null, якщо default на сервері
      ),
    );
  }

  String formattedDate(DateTime? dateTime) {
    if (dateTime != null) {
      final local = dateTime.toLocal();
      final data = DateFormat('dd.MM.yyyy HH:mm', 'uk_UA').format(local);
      return data;
    } else {
      return "триває";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 11, 2),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(23, 13, 2, 1),
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color.fromARGB(255, 247, 135, 50),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            color: const Color.fromARGB(255, 247, 135, 50),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Stack(
        children: [
            const Positioned(
                    left: -50,
                    right: -50,
                    top: -50,
                    bottom: -50,
                    child: Image(
                      image: AssetImage("assets/back.png"),
                      color: Color.fromARGB(32, 41, 41, 41),
                    ),
                  ),
                  const Positioned(
                    left: -350,
                    right: -350,
                    bottom: -250,
                    top: -100,
                    child: Image(
                      image: AssetImage("assets/radiation.png"),
                      color: Color.fromARGB(15, 54, 27, 6),
                    ),
                  ),
          LayoutBuilder(
            builder: (context, constraints) {
              return BlocBuilder<AlarmHistoryBloc, AlarmHistoryBlocState>(
                builder: (context, state) {
                  if (state is LoadingState) {
                    return Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RadiationLoader(color: Color.fromARGB(255, 247, 135, 50)),
                          RadiationLoaderText(
                            text: "Завантаження даних",
                            style: TextStyle(
                              color: Color.fromARGB(255, 186, 102, 38),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (state is LoadedState) {
                    return ListView.separated(
                      itemCount: state.listOfModel.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 2, // товщина лінії
                              width: double.infinity,
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(72, 232, 136, 27),
                                ),
                              ),
                            ),
                            Container(
                              color: const Color.fromARGB(4, 249, 189, 25),
          
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: constraints.maxWidth * 0.02,
                                      top: constraints.maxHeight * 0.01,
                                      bottom: constraints.maxHeight * 0.01,
                                    ),
                                    child: Row(
                                      children: [
                                        Image(
                                          image: AssetImage("assets/megaphone.png"),
                                          color: Colors.red,
                                          height: constraints.maxHeight * 0.05,
                                          fit: BoxFit.cover,
                                          width: constraints.maxWidth * 0.15,
                                        ),
                                        SizedBox(
                                          width: constraints.maxWidth * 0.02,
                                        ),
                                        Text(
                                          "Викид \n${state.listOfModel[index].locationTitle}",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                              255,
                                              247,
                                              135,
                                              50,
                                            ),
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 2, // товщина лінії
                                    width: double.infinity,
                                    child: const DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: bottomGradient,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: constraints.maxWidth * 0.48,
                                        child: Text(
                                          AlarmUiFormat.dateRangeLabel(
                                            state.listOfModel[index].startedAt,
                                            state.listOfModel[index].finishedAt,
                                          ),
                                          style: TextStyle(
                                            color:
                                                state
                                                        .listOfModel[index]
                                                        .finishedAt ==
                                                    null
                                                ? Colors.red
                                                : Color.fromARGB(255, 247, 135, 50),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      GradientVerticalDivider(
                                        gradient: verticalGradient,
                                        thickness: 1.5,
                                        height: constraints.maxHeight * 0.1,
                                      ),
                                      Container(
                                        width: constraints.maxWidth * 0.48,
                                        child: Text(
                                          AlarmUiFormat.durationLabel(
                                            state.listOfModel[index].startedAt,
                                            state.listOfModel[index].finishedAt,
                                          ),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color:
                                                state
                                                        .listOfModel[index]
                                                        .finishedAt ==
                                                    null
                                                ? Colors.red
                                                : Color.fromARGB(255, 247, 135, 50),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
          
                            SizedBox(height: constraints.maxHeight * 0.04),
                          ],
                        );
                      },
                      separatorBuilder: (_, __) => Container(
                        height: 0,
                        decoration: BoxDecoration(gradient: bottomGradient),
                      ),
                    );
                  } else {
                    return Text("Something went wrong");
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
