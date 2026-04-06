import '../Entities/animal_entity.dart';

abstract class AnimalRepository {
  Future<List<AnimalEntity>> getAnimals();
  Future<AnimalEntity> getAnimalById(String id);
  Future<AnimalEntity> addAnimal(AnimalEntity animal);
  Future<AnimalEntity> updateAnimal(AnimalEntity animal);
  Future<void> deleteAnimal(String id);
  Future<AnimalEntity> verifyAnimal(String id);
  Future<List<AnimalEntity>> getAnimalsByFarmId(String farmId);
}