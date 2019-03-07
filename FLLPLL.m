% Filename: FLLPLL.m                                                 2018-03-01
%
clear all;
close all;
RefFreq = 9548000;
OutFreq = 9548005;
FSample = 38192000;
PDItime = 0.001;  % PreDetection Interval // typically 1 ms
ref = NCO(5, FSample);
out = NCO(5, FSample);
ref.SetFrequency(RefFreq);  % Fc = 9.548e6
out.SetFrequency(OutFreq);
I1 = I2 = Q1 = Q2 = 1;
Phi = LastPhi = 0;
Error = LastError = 0;
Tau1 = 1 / (47.14 * 47.14);
Tau2 = 2 * 0.707 / 47.14;
Wn = 47.14;
printf("Tau1: %5.3g Tau2: %5.3g Wn: %5.3g Ref: %7.0f\n",...
        Tau1, Tau2, Wn, RefFreq);

for idx = 1:500
 for n = 1:(FSample*PDItime)
  ref.clock();
  out.clock();
  Q1 = Q1 + ref.costable(ref.index) * out.costable(out.index);
  I1 = I1 + ref.sintable(ref.index) * out.sintable(out.index);
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
  Q2 = Q2 + ref.costable(ref.index) * out.costable(out.index);
  I2 = I2 + ref.sintable(ref.index) * out.sintable(out.index);
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
printf("%3d FErr:%9.3f dF:%9.3f Phi: %7.0f F:%7.0f\n",...
       idx, FreqError, E(idx), Phi, out.Frequency);
%plot(E);
%out.SetFrequency(out.Frequency + FreqError * 1.0); % How much adjustment?
I1 = I2 = Q1 = Q2 = 1;
end % of 30 sample for loop (60 ms)
plot(E);