/// The exact SI definition of a pound, used both ways so a round trip
/// through [kgToLb] and [lbToKg] returns the original value.
const double _kgPerLb = 0.45359237;

double kgToLb(double kg) => kg / _kgPerLb;

double lbToKg(double lb) => lb * _kgPerLb;

bool isImperial(String? unitSystem) => unitSystem == 'imperial';

String unitLabelFor(String? unitSystem) => isImperial(unitSystem) ? 'lb' : 'kg';
