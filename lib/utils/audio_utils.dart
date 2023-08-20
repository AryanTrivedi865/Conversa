import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AudioBottomSheet extends StatefulWidget {
  const AudioBottomSheet({super.key});

  @override
  State<AudioBottomSheet> createState() => AudioBottomSheetState();
}

class AudioBottomSheetState extends State<AudioBottomSheet> {
  bool isRecording = false;
  bool recorded = false;

  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _build(),
      floatingActionButton: _buildFAB(),
    );
  }

  _build() {
    if (!recorded) {
      return isRecording
          ? Center(
              child: Lottie.asset(
                'assets/lottie_animation/mic.json',
                width: MediaQuery.of(context).size.width * 0.3,
                fit: BoxFit.contain,
              ),
            )
          : Center(
              child: Container(
                height: MediaQuery.of(context).size.width * 0.285,
                width: MediaQuery.of(context).size.width * 0.285,
                decoration: BoxDecoration(
                  color: Colors.green,
                  border: Border.all(
                    color: Colors.white,
                    width: 6,
                  ),
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.6),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width * 0.13,
                  ),
                  onPressed: () {
                    setState(
                      () {
                        isRecording = true;
                      },
                    );
                  },
                ),
              ),
            );
    } else {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: MediaQuery.of(context).size.width * 0.14,
                width: MediaQuery.of(context).size.width * 0.14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.6),
                ),
                child: IconButton(
                  color: Colors.green,
                  onPressed: () {
                    setState(
                      () {
                        isPlaying = !isPlaying;
                      },
                    );
                  },
                  icon: isPlaying
                      ? Icon(
                          Icons.pause,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
                ),
              ),
              Slider(
                value: 50,
                onChanged: (value) {},
                activeColor: Colors.green,
                min: 0,
                max: 100,
              ),
              Container(
                height: MediaQuery.of(context).size.width * 0.075,
                width: MediaQuery.of(context).size.width * 0.125,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.05),
                ),
                child: Center(
                  child: Text(
                    '00:00',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }
  }

  _buildFAB() {
    if (isRecording) {
      return FloatingActionButton(
        backgroundColor: Colors.green,
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
        onPressed: () {
          setState(
            () {
              isRecording = false;
              recorded = true;
            },
          );
        },
      );
    } else if(recorded) {
      return Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
            child: FloatingActionButton(
              backgroundColor: Colors.green,
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
              onPressed: () {
                setState(
                  () {
                    isRecording = false;
                    recorded = false;
                  },
                );
              },
            ),
          ),
          const Spacer(),
          FloatingActionButton(
            backgroundColor: Colors.green,
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
            onPressed: () {
              setState(
                () {
                  isRecording = false;
                  recorded = true;
                },
              );
            },
          )
        ],
      );
    }
  }
}
