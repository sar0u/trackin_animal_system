import '../Entities/animal_entity.dart';
import '../Repositories/animal_repository.dart';

class GetAnimalsUseCase {
  final AnimalRepository _repository;

  GetAnimalsUseCase({required AnimalRepository repository}) : _repository = repository;

  Future<List<AnimalEntity>> execute() async {
    return await _repository.getAnimals();
  }
}