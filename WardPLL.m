% Filename: WardPLL.m                                                 2018-03-22
% Implementation of Ward's 2nd Order digital loop filter PLL from (Kaplan, 1996)

clear all;
close all;

RefFreq = 9548000;
OutFreq = 9548012;
FSample = 38192000;
PDItime = 0.005;  % PreDetection Interval // typically 1 ms
out = NCO(5, FSample);
ref = NCO(2, FSample);
ref.SetFrequency(RefFreq);  % Fc = 9.548e6
out.SetFrequency(OutFreq);
I1 = I2 = Q1 = Q2 = 1;
Phi = LastPhi = 0;
Error = LastError = 0;
Bn = 18;
W0 = Bn / 0.53;
a2W0 = 1.414 * W0;
T = PDItime;

printf("Bn: %3d W0: %5.3g a2W0: %5.3g W0^2: %5.2f Ref: %7.0f\n",...
        Bn, W0, a2W0, W0.^2, RefFreq);
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
 Ips1 = I1 / (FSample*PDItime);
 Qps1 = Q1 / (FSample*PDItime);
 Error = atan(Qps1/Ips1)/(2*pi);
 Phi = LastPhi + (W0.^2 * PDItime/2 + a2W0) * Error +...
                 (W0.^2 * PDItime/2 - a2W0) * LastError;
 Phi = Phi / (2*pi); % Uhm, why is this needed?
 LastPhi = Phi;
 LastError = Error;
 out.SetFrequency(out.Frequency - Phi); % How much adjustment?
% printf("Carrier Error: %9.3f Phi: %9.3f\n", Error, Phi);

 for n = 1:(FSample*PDItime)
  ref.clock();
  out.clock();
  SampleData = ref.sintable(ref.index);
  I2 = I2 + SampleData * out.sintable(out.index);
  Q2 = Q2 + SampleData * out.costable(out.index);
 end % second ms (or PDI interval) of samples
 Ips2 = I2 / (FSample*PDItime);
 Qps2 = Q2 / (FSample*PDItime);
 Error = atan(Qps2/Ips2)/(2*pi);
 Phi = LastPhi + (W0.^2 * PDItime/2 + a2W0) * Error +...
                 (W0.^2 * PDItime/2 - a2W0) * LastError;
 Phi = Phi / (2*pi); % Uhm, why is this needed?
 LastPhi = Phi;
 LastError = Error;
 out.SetFrequency(out.Frequency - Phi); % How much adjustment?
% printf("Carrier Error: %9.3f Phi: %9.3f\n", Error, Phi);

dot   = I1 * I2 + Q1 * Q2;
cross = I1 * Q2 - I2 * Q1;
FreqError = atan2(cross, dot)/(2 * pi * PDItime);
E(idx) = out.Frequency - RefFreq;
printf("%3d FErr:%9.3f dF:%9.3f Phi: %7.3f F:%7.0f\n",...
       idx, FreqError, E(idx), Phi, out.Frequency);
%out.SetFrequency(out.Frequency + FreqError); % How much adjustment?
I1 = I2 = Q1 = Q2 = 1;
end % of N sample for loop
plot(E);