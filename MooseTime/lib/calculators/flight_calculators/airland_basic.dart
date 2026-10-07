import 'flight_parent_calculator.dart';

class AirlandBasic extends FlightParentCalculator {
  AirlandBasic({
    required super.zuluTakeoffTime,
    super.showtimeAdjustment,
    super.stationtimeAdjustment,
    super.zuluConstant,
  }) : super(
          augmentVariable: false,
          qualifyingLeg: false,
          alertOffset: const Duration(
            hours: 3,
            minutes: 45,
          ),
        );
}