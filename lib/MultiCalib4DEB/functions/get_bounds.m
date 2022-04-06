function [ bounds ] = get_bounds(params, factor, type)

   if strcmp(type, 'sum')
      par_maxs = params + factor;
      par_mins = params - factor;
      par_mins(par_mins < 0) = 0;
      disp(params');
   else
      par_maxs = params * (1.0 + factor);
      par_mins = params * (1.0 - factor);
      par_mins(par_mins < 0) = 0;
   end
   
   bounds = [par_mins ; par_maxs];
   
end
