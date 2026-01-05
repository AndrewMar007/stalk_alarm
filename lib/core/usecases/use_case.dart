import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../exceptions/failures.dart';

abstract class UseCase<TypeOf, Params> {
  Future<Either<Failure, TypeOf>> call(Params params);
}


class NoParams extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}