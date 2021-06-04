part of 'files_cubit.dart';

@immutable
abstract class FilesState {
  const FilesState();
}

class NoFiles extends FilesState {
  const NoFiles() : super();
}

class Files extends FilesState {
  final List<String> fileNames;
  const Files({this.fileNames}) : super();
}

class LoadingFiles extends FilesState {}
