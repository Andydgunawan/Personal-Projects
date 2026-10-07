import 'flight_parent_calculator.dart';

class AirdropBasic extends FlightParentCalculator {
  AirdropBasic({
    required super.zuluTakeoffTime,
    super.showtimeAdjustment,
    super.stationtimeAdjustment,
    super.zuluConstant,
  }) : super(
          augmentVariable: false,
          qualifyingLeg: false,
          alertOffset: const Duration(
            hours: 4,
            minutes: 15,
          ),
        );
}