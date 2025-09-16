import 'rental_unit.dart';

class Property {
  Property({
    required this.id,
    required this.name,
    required this.address,
    this.description,
    List<RentalUnit>? units,
  }) : units = units ?? <RentalUnit>[];

  final String id;
  final String name;
  final String address;
  final String? description;
  final List<RentalUnit> units;

  int get occupiedUnitCount =>
      units.where((unit) => unit.isOccupied).length;

  int get vacantUnitCount => units.length - occupiedUnitCount;
}
