abstract class UseCase<Result, Params> {

  Future<Result> execute(Params? params);
}
