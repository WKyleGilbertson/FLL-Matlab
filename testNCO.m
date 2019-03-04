% Filename: testNCO.m                                                2018-03-01
%
clear all;
close all;
a = NCO(5, 38.192e6);
a.SetFrequency(9.548e6);  % Fc = 9.548e6
printf("length: %d mask: %d dPhase: %d\n", a.tablelength, a.mask, a.deltaPhase);
%plot(a.sintable, 'r*-', a.costable, 'bo-');
%legend('sine', 'cosine');
for n = 1:36
  a.Counter;
  printf("%10d %10d %3d %6.3f %6.3f\n",...
  a.Counter, a.BigCounter, a.index, a.sintable(a.index), a.costable(a.index));
  a.clock();
end