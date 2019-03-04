clear all;
close all;
RefFreq = 9548000;
OutFreq = 9548500;
ref = NCO(5, 38.192e6);
out = NCO(5, 38.192e6);
ref.SetFrequency(RefFreq);  % Fc = 9.548e6
out.SetFrequency(OutFreq);

for idx = 1:10
for n = 1:38192
  ref.clock();
  out.clock();
  Q1 = ref.costable(ref.index+1) * out.costable(out.index+1);
  I1 = ref.sintable(ref.index+1) * out.sintable(out.index+1);
end % first ms/2 of samples
for n = 1:38192
  ref.clock();
  out.clock();
  Q2 = ref.costable(ref.index+1) * out.costable(out.index+1);
  I2 = ref.sintable(ref.index+1) * out.sintable(out.index+1);
end % second ms/2 of samples

dot = I1 * I2 + Q1 * Q2;
cross = I1 * Q2 - I2 * Q1;
FreqError = atan2(cross, dot)/(2 * pi * 0.001);
printf("%3d %6.3f\n", idx, FreqError);
out.SetFrequency(out.Frequency + FreqError * 0.2); % How much adjustment?
end % of 20 sample for loop
