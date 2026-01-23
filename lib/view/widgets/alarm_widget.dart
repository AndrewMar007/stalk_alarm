import 'package:flutter/material.dart';
import 'package:stalc_alarm/view/widgets/gradient_outline_border_button.dart';

const bottomButtonGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color.fromARGB(169, 248, 138, 41),
    Color.fromARGB(4, 249, 189, 25),
    Color.fromARGB(4, 249, 189, 25),
    Color.fromARGB(169, 248, 138, 41),
  ],
  stops: [0.02, 0.4, 0.9, 1.0],
);

const topButtonGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color.fromARGB(169, 248, 138, 41),
    Color.fromARGB(4, 249, 189, 25),
    Color.fromARGB(4, 249, 189, 25),
    Color.fromARGB(169, 248, 138, 41),
  ],
  stops: [0.02, 0.6, 0.8, 1.0],
);

class AlertDialogWidget extends StatelessWidget {
  final String title;
  final String content;
  final String acceptButtonText;
  final String cancelButtonText;
  final VoidCallback? onAcceptPressed;
  final VoidCallback? onCancelPressed;

  const AlertDialogWidget({
    super.key,
    required this.title,
    required this.content,
    required this.acceptButtonText,
    required this.cancelButtonText,
    required this.onAcceptPressed,
    required this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 4-кольоровий градієнт для бордера (можеш поміняти під себе)
    const borderGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromARGB(255, 248, 138, 41), // 1
        Color.fromRGBO(23, 13, 2, 1), // 2
        Color.fromARGB(255, 248, 138, 41), // 3
        Color.fromRGBO(23, 13, 2, 1), // 4 (замикання)
      ],
      stops: [0.1, 0.2, 0.8, 0.9],
    );

    // Фон діалога
    const dialogBg = Color.fromRGBO(23, 13, 2, 1);

    // Товщина бордера
    const borderWidth = 2.0;

    // Радіус
    const radius = 18.0;
    const bg = Color.fromRGBO(23, 13, 2, 1);
    const accent = Color.fromARGB(255, 248, 137, 41);
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        final dialogW = (w * 0.8).clamp(240.0, 300.0);
        final dialogH = (h * 0.2).clamp(400.0, 540.0);
        return Dialog(
          backgroundColor: Colors.transparent, // щоб був видний градієнт-бордер
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: SizedBox(
            height: dialogH,
            width: dialogW,
            child: Container(
              decoration: BoxDecoration(
                gradient: borderGradient,
                borderRadius: BorderRadius.circular(radius),
              ),
              padding: const EdgeInsets.all(borderWidth),
              child: Container(
                decoration: BoxDecoration(
                  color: dialogBg,
                  borderRadius: BorderRadius.circular(radius - borderWidth),
                ),
                // ТУТ уже сам AlertDialog, але з прозорим фоном (фон дає контейнер вище)
                child: AlertDialog(
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 24,
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  actionsPadding: const EdgeInsets.only(bottom: 8, top: 20),
                  titlePadding: const EdgeInsets.only(
                    top: 12,
                    left: 16,
                    right: 16,
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Column(
                    children: [
                      Icon(
                        Icons.location_off_rounded,
                        color: Color.fromARGB(255, 247, 135, 50),
                        size: 100,
                      ),
                      SizedBox(height: 20),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFF88729),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  content: Text(
                    content,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color.fromARGB(200, 248, 137, 41),
                    ),
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: <Widget>[
                    GradientBorderButton(
                      topGradient: topButtonGradient,
                      bottomGradient: bottomButtonGradient,
                      radius: 30,
                      strokeWidth: 1,
                      onTap: onAcceptPressed,
                      child: SizedBox(
                        height: 40,
                        width: 80,
                        child: Center(
                          child: Text(
                            'Так',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: accent),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    GradientBorderButton(
                      topGradient: topButtonGradient,
                      bottomGradient: bottomButtonGradient,
                      radius: 30,
                      strokeWidth: 1,
                      onTap: onCancelPressed,
                      child: SizedBox(
                        width: 80,
                        height: 40,
                        child: Center(
                          child: Text(
                            'Ні',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: accent),
                          ),
                        ),
                      ),
                    ),
                    // TextButton(
                    //   onPressed: onAcceptPressed,
                    //   child: Text(
                    //     acceptButtonText,
                    //     style: const TextStyle(color: Color(0xFFF88729)),
                    //   ),
                    // ),
                    // TextButton(
                    //   onPressed: onCancelPressed,
                    //   child: Text(
                    //     cancelButtonText,
                    //     style: const TextStyle(
                    //       color: Color.fromARGB(180, 248, 137, 41),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
