import 'package:dartz/dartz.dart';
import 'failure.dart';

/// Type alias for Either with Failure on the left
typedef Result<T> = Either<Failure, T>;

/// Type alias for Future Either with Failure on the left
typedef FutureResult<T> = Future<Either<Failure, T>>;
