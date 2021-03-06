% Filename: FLL.m                                                    2018-03-01
%
clear all;
close all;
RefFreq = 9548000;
OutFreq = 9548250;
FSample = 38192000;
PDItime = 0.001;  % PreDetection Interval // typically 1 ms
ref = NCO(3, FSample);
out = NCO(5, FSample);
ref.SetFrequency(RefFreq);  % Fc = 9.548e6
out.SetFrequency(OutFreq);
I1 = I2 = Q1 = Q2 = 1;

for idx = 1:30
 for n = 1:(FSample*PDItime)
  ref.clock();
  out.clock();
  SampleData = ref.sintable(ref.index);
  I1 = I1 + SampleData * out.sintable(out.index);
  Q1 = Q1 + SampleData * out.costable(out.index);
%  if n == 1
%   printf("%ld %ld ", I1, Q1);
%  end
 end % first ms (or PDI interval) of samples
 for n = 1:(FSample*PDItime)
  ref.clock();
  out.clock();
  SampleData = ref.sintable(ref.index);
  I2 = I2 + SampleData * out.sintable(out.index);
  Q2 = Q2 + SampleData * out.costable(out.index);
 end % second ms (or PDI interval) of samples

dot   = I1 * I2 + Q1 * Q2;
cross = I1 * Q2 - I2 * Q1;
FreqError = atan2(cross, dot)/(2 * pi * PDItime);
NewFreq = out.Frequency + FreqError * 1.0;
printf("%3d CalcErr:%9.3f ActErr:%11.3f Fnow:%11.3f Fnxt:%11.3f\n",...
        idx, FreqError, out.Frequency - ref.Frequency, out.Frequency, NewFreq);
out.SetFrequency(NewFreq);
%printf("%ld %ld %ld %ld %f %f\n", I1, Q1, I2, Q2, cross, dot);
I1 = I2 = Q1 = Q2 = 1;
end % of 30 sample for loop (60 ms)
