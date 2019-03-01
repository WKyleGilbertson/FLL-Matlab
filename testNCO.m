clear all;
close all;
a = NCO(5, 38.192e6);
a.frequency(9.548e6);  % Fc = 9.548e6
printf("length: %d mask: %d dPhase: %d\n", a.tablelength, a.mask, a.deltaPhase);
%plot(a.sintable, 'r*-', a.costable, 'bo-');
%legend('sine', 'cosine');
for n = 1:36
  a.Counter;
  printf("%10d %10d %3d %6.3f %6.3f\n",...
  a.Counter, a.BigCounter, a.index, a.sintable(a.index+1), a.costable(a.index+1));
  a.clock();
end