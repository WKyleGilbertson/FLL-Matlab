% Filename: FLLPLL.m                                                 2018-03-01
%
clear all;
close all;
function [Tau1, Tau2, Wn] = CalcLoopCoef(LBW, zeta, k)
 Wn = Wn = LBW*8*zeta / (4*zeta.^2 + 1);
 Tau1 = k / (Wn.^2);
 Tau2 = 2.0 * zeta / Wn;
end

RefFreq = 9548000;
OutFreq = 9548350;
FSample = 38192000;
PDItime = 0.001;  % PreDetection Interval // typically 1 ms
ref = NCO(5, FSample);
out = NCO(5, FSample);
ref.SetFrequency(RefFreq);  % Fc = 9.548e6
out.SetFrequency(OutFreq);
I1 = I2 = Q1 = Q2 = 1;
Phi = LastPhi = 0;
Error = LastError = 0;
[Tau1, Tau2, Wn] = CalcLoopCoef(25, 0.707, 1.0);
printf("Tau1: %5.3g Tau2: %5.3g Wn: %5.2f Ref: %7.0f\n",...
        Tau1, Tau2, Wn, RefFreq);
idx = 0; 
%while (abs(out.Frequency - RefFreq) > 1 && abs(out.Frequency - RefFreq) < 1000)
%idx = idx + 1;
for idx = 1:500
 for n = 1:(FSample*PDItime)
  ref.clock();
  out.clock();
  SampleData = ref.sintable(ref.index);
  I1 = I1 + SampleData * out.sintable(out.index);
  Q1 = Q1 + SampleData * out.costable(out.index);
 end % first ms (or PDI interval) of samples
 Error = atan2(Q1,I1)/(2*pi); % Should be just atan(Q1/I1)
 Phi = LastPhi + Tau2/Tau1 * (Error - LastError) + Error * (PDItime/Tau1);
 LastPhi = Phi;
 LastError = Error;
 out.SetFrequency(out.Frequency - Phi * 1.0); % How much adjustment?
% printf("Carrier Error: %9.3f Phi: %9.3f\n", Error, Phi);

 for n = 1:(FSample*PDItime)
  ref.clock();
  out.clock();
  SampleData = ref.sintable(ref.index);
  I2 = I2 + SampleData * out.sintable(out.index);
  Q2 = Q2 + SampleData * out.costable(out.index);
 end % second ms (or PDI interval) of samples
 Error = atan2(Q2,I2)/(2*pi); % Should be just atan(Q1/I1)
 Phi = LastPhi + Tau2/Tau1 * (Error - LastError) + Error * (PDItime/Tau1);
 LastPhi = Phi;
 LastError = Error;
 out.SetFrequency(out.Frequency - Phi * 1.0); % How much adjustment?
% printf("Carrier Error: %9.3f Phi: %9.3f\n", Error, Phi);

dot   = I1 * I2 + Q1 * Q2;
cross = I1 * Q2 - I2 * Q1;
FreqError = atan2(cross, dot)/(2 * pi * PDItime);
E(idx) = out.Frequency - RefFreq;
printf("%3d FErr:%9.3f dF:%9.3f Phi: %3.0f F:%7.0f\n",...
       idx, FreqError, E(idx), Phi, out.Frequency);
%out.SetFrequency(out.Frequency + FreqError * 1.0); % How much adjustment?
I1 = I2 = Q1 = Q2 = 1;
end % of 30 sample for loop (60 ms)
plot(E);