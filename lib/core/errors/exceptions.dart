import 'error_model.dart';

class ServerException implements Exception
{
  final ErrorMessageModel errorMessageModel;
  const ServerException({
    required this.errorMessageModel,
});
}
