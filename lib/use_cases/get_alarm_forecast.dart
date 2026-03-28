import 'package:fpdart/fpdart.dart';

import '../core/exceptions/failures.dart';
import '../core/usecases/use_case.dart';
import '../models/forecast_model.dart';
import '../view_model/alarm_forecast_view_model.dart';

class GetAlarmForecastUseCase extends UseCase<OblastForecastResponse, AlarmForecastParams> {
  final AlarmForecastViewModel viewModel;
  GetAlarmForecastUseCase({required this.viewModel});

  @override
  Future<Either<Failure, OblastForecastResponse>> call(
    AlarmForecastParams params,
  ) async {
    return await viewModel.getForecast(
      oblastId: params.oblastId
    );
  }
}

class AlarmForecastParams {
  final int oblastId;
  AlarmForecastParams({required this.oblastId});
}
