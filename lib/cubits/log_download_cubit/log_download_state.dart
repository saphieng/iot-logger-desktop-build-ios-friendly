part of 'log_download_cubit.dart';

@immutable
abstract class LogDownloadState {
  final String date;
  final double progress;
  final LogStatus status;
  final Widget icon;

  const LogDownloadState({this.date, this.progress, this.status, this.icon});
}

class LogLoaded extends LogDownloadState {
  const LogLoaded({String date, double progress, LogStatus status, Widget icon})
      : super(date: date, progress: progress, status: status, icon: icon);
}

class LogDownloading extends LogDownloadState {
  const LogDownloading({double progress}) : super(progress: progress);
}

class LogDownloaded extends LogDownloadState {
  const LogDownloaded() : super();
}
