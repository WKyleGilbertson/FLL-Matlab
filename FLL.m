% Filename: FLL.m                                                    2018-03-01
%
clear all;
close all;
RefFreq = 9548000;
OutFreq = 9547900;
FSample = 38192000;
PDItime = 0.001;  % PreDetection Interval // typically 1 ms
ref = NCO(5, FSample);
out = NCO(5, FSample);
ref.SetFrequency(RefFreq);  % Fc = 9.548e6
out.SetFrequency(OutFreq);
I1 = I2 = Q1 = Q2 = 1;

for idx = 1:25
 for n = 1:(FSample*PDItime)
  ref.clock();
  out.clock();
  Q1 = Q1 + ref.costable(ref.index) * out.costable(out.index);
  I1 = I1 + ref.sintable(ref.index) * out.sintable(out.index);
 end % first ms (or PDI interval) of samples
 for n = 1:(FSample*PDItime)
  ref.clock();
  out.clock();
  Q2 = Q2 + ref.costable(ref.index) * out.costable(out.index);
  I2 = I2 + ref.sintable(ref.index) * out.sintable(out.index);
 end % second ms (or PDI interval) of samples

dot   = I1 * I2 + Q1 * Q2;
cross = I1 * Q2 - I2 * Q1;
FreqError = atan2(cross, dot)/(2 * pi * PDItime);
NewFreq = out.Frequency + FreqError * 1.0;
printf("%3d CalcErr:%9.3f ActErr:%11.3f Fnow:%11.3f Fnxt:%11.3f\n",...
        idx, FreqError, out.Frequency - ref.Frequency, out.Frequency, NewFreq);
out.SetFrequency(NewFreq);
I1 = I2 = Q1 = Q2 = 1;
end % of 30 sample for loop (60 ms)
