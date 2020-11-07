import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingPage extends StatelessWidget {
  final VoidCallback onboardingDoneCallback;

  OnboardingPage({this.onboardingDoneCallback});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      done: Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
      onDone: () {
        onboardingDoneCallback();
      },
      showSkipButton: true,
      skip: Text('Skip'),
      next: Icon(Icons.navigate_next),
      pages: <PageViewModel>[
        PageViewModel(
          title: 'Tracking Time',
          bodyWidget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Tap on the '),
              Icon(Icons.timer),
              Text(' button to clock in and out'),
            ],
          ),
          image: Center(child: Icon(Icons.android)),
        ),
        PageViewModel(
          title: 'Logged Hours',
          bodyWidget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('View all of your logged time on'),
              Text('the "Logged Hours" page'),
            ],
          ),
          image: Center(child: Icon(Icons.android)),
        ),
        PageViewModel(
          title: 'Time Change Requests',
          bodyWidget: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Click on '),
                  Icon(Icons.report),
                  Text(' to request a time change'),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Text('You have to clock in at least once on the day'),
              Text('you would like to submit a time request'),
              Text('or the option will not be available')
            ],
          ),
          image: Center(child: Icon(Icons.android)),
        ),
        PageViewModel(
          title: 'Leaderboard',
          bodyWidget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Compare your total hours with the rest of'),
              Text('your team on the "Leaderboard" page'),
            ],
          ),
          image: Center(child: Icon(Icons.android)),
        ),
      ],
      dotsDecorator: DotsDecorator(
        activeColor: Colors.indigoAccent,
      ),
    );
  }
}
