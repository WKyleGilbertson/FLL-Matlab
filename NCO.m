% Filename: NCO.m                                                    2018-03-01
% Constructor: (<table_width>, <sample_rate>)
% SetFrequency(<desired_frequency>)
%
classdef NCO < handle
   properties
     ONE_ROTATION = double(2^32) % The type changes dPhase!
     SAMPLE_RATE
     Frequency
     BigCounter
     Counter
     deltaPhase
     tablelength
     tablewidth
     sintable
     costable
     mask
     index
   end % of properties
   methods
     function self = NCO(val1,val2)
       if nargin == 2
         if isnumeric(val1)
          self.tablewidth = val1;
          self.tablelength = bitshift(1,val1);
          self.SAMPLE_RATE = double(val2);
          self.mask = self.tablelength - 1;
          for n = 1:self.tablelength
            self.sintable(n) = sin(2.0 * pi * n / self.tablelength);
            self.costable(n) = cos(2.0 * pi * n / self.tablelength);
            self.Counter = uint32(0);
            self.deltaPhase = uint32(0);
            self.BigCounter = uint64(0);
            self.index = 0;
          end % of for loop
         else
          error('Value must be numeric');
         end % of is-numeric
       end % of nargin
     end % of function class constructor
     function self = SetFrequency(self, arg1)
       self.Frequency = arg1;
       self.deltaPhase = uint32(arg1 * self.ONE_ROTATION / self.SAMPLE_RATE);
     end % of function frequency
     function self = clock(self)
       self.BigCounter = self.BigCounter + uint64(self.deltaPhase);
       if self.BigCounter >= intmax('uint32');
         self.BigCounter = self.BigCounter - uint64(intmax('uint32'));
       end % of Counter size test to allow roll-over
       self.Counter = uint32(self.BigCounter);
       self.index = bitshift(self.Counter, self.tablewidth - 32);
%       self.index = bitand(self.mask, self.index);
       end % of function clk
   end % of methods
end % of classdef