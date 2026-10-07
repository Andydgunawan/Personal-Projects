import 'flight_parent_calculator.dart';

class AirlandAugmented extends FlightParentCalculator {
  AirlandAugmented({
    required super.zuluTakeoffTime,
    super.showtimeAdjustment,
    super.stationtimeAdjustment,
    super.zuluConstant,
    super.qualifyingLeg,
  }) : super(
          augmentVariable: true,
          alertOffset: const Duration(
            hours: 3,
            minutes: 45,
          ),
        );
}