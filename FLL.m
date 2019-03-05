% Filename: FLL.m                                                    2018-03-01
%
clear all;
close all;
RefFreq = 9548000;
OutFreq = 9548500;
FSample = 38192000;
PDItime = 0.001;  % PreDetection Interval // typically 1 ms
ref = NCO(5, FSample);
out = NCO(5, FSample);
ref.SetFrequency(RefFreq);  % Fc = 9.548e6
out.SetFrequency(OutFreq);

for idx = 1:30
 for n = 1:(FSample*PDItime)
  ref.clock();
  out.clock();
  Q1 = ref.costable(ref.index) * out.costable(out.index);
  I1 = ref.sintable(ref.index) * out.sintable(out.index);
 end % first ms (or PDI interval) of samples
 for n = 1:(FSample*PDItime)
  ref.clock();
  out.clock();
  Q2 = ref.costable(ref.index) * out.costable(out.index);
  I2 = ref.sintable(ref.index) * out.sintable(out.index);
 end % second ms (or PDI interval) of samples

dot   = I1 * I2 + Q1 * Q2;
cross = I1 * Q2 - I2 * Q1;
FreqError = atan2(cross, dot)/(2 * pi * PDItime);
printf("%3d %9.3f\n", idx, FreqError);
out.SetFrequency(out.Frequency + FreqError / 8); % How much adjustment?
end % of 30 sample for loop (60 ms)
