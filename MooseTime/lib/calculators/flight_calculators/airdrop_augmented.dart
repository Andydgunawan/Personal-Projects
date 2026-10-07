import 'flight_parent_calculator.dart';

class AirdropAugmented extends FlightParentCalculator {
  AirdropAugmented({
    required super.zuluTakeoffTime,
    super.showtimeAdjustment,
    super.stationtimeAdjustment,
    super.zuluConstant,
    super.qualifyingLeg,
  }) : super(
          augmentVariable: true,
          alertOffset: const Duration(
            hours: 4,
            minutes: 15,
          ),
        );
}