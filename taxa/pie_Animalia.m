%% pie_Animalia
% counts number of entries in Animalia and presents a pie of it

%%
function [x taxa] = pie_Animalia (n)
% created 2016/02/21 by Bas Kooijman

%% Syntax
% [x taxa] = <../pie_Animalia.m *pie_Animalia*> (n)

%% Description
% The kingdom Animalia can be partitioned into various taxa. 
% The number of species in the add_my_pet collection are counted for these taxa and the result is presented in a pie
%
% Input:
%
% * n: optional scalar with number of pie-pieces (2 till 8). Default n = 7.
%
% Output (apart from figure):
% 
% * x: n-vector containing species counts in taxa
% * taxa: n-vector with names of taxa

%% Remarks
% sum(x) = total number of animal species in the add_my_pet collection

%% Example of use
% pie_Animalia; or [n taxa] = pie_Animalia(6);

  if ~exist('n', 'var')
      n = 7;
  end
  
  switch n
    case 2
      taxa = {'Animalia'; 'Vertebrata'};    
      n = length(taxa); x = zeros(n, 1);
      for i = 1:n
        x(i) = length(select(taxa{i}));
      end
      x(1) = x(1) - x(2); taxa{1} = 'evertebrates';     
    case 3
      taxa = {'Radiata'; 'Protostomata'; 'Deuterostomata'};
      n = length(taxa); x = zeros(n, 1);
      for i = 1:n
        x(i) = length(select(taxa{i}));
      end
    case 4
      taxa = {'Radiata'; 'Chaetognatha'; 'Spiralia'; 'Ecdysozoa'; 'Deuterostomata'};
      n = length(taxa); x = zeros(n, 1);
      for i = 1:n
        x(i) = length(select(taxa{i}));
      end
      x(2) = sum(x([1 2])); taxa{2} = 'rad + chaeto'; x(1) = []; taxa(1) = [];
    case 5
      TAXA = {'Radiata'; 'Protostomata'; 'Echinodermata'; 'Cephalochordata'; 'Tunicata'; 'Myxini'; 'Agnatha'; 'Chondrichthyes'; 'Actinopterygii'; 'Actinistia'; 'Dipnoi'; 'Amphibia'; 'Sauropsida'; 'Aves'; 'Mammalia'};    
      n = length(TAXA); y = zeros(n, 1);
      for i = 1:n
        y(i) = length(select(TAXA{i}));
      end
      x(1) = sum(y(1:5)); taxa{1} = 'acraniates';
      x(2) = sum(y(6:11)); taxa{2} = 'fish';
      x(3) = sum(y(12:13)) - y(14); taxa{3} = 'amph + rept';
      x(4) = y(14); taxa{4} = 'birds';
      x(5) = y(15); taxa{5} = 'mammals';
    case 6
      TAXA = {'Radiata'; 'Protostomata'; 'Echinodermata'; 'Cephalochordata'; 'Tunicata'; 'Myxini'; 'Agnatha'; 'Chondrichthyes'; 'Actinopterygii'; 'Actinistia'; 'Dipnoi'; 'Amphibia'; 'Sauropsida'; 'Aves'; 'Mammalia'};    
      n = length(TAXA); y = zeros(n, 1);
      for i = 1:n
        y(i) = length(select(TAXA{i}));
      end
      x(1) = sum(y(1:2)); taxa{1} = 'rad + proto';
      x(2) = sum(y(3:5));  taxa{2} = 'acraniate deut';
      x(3) = sum(y(6:11)); taxa{3} = 'fish';
      x(4) = sum(y(12:13)) - y(14); taxa{4} = 'amph + rept';
      x(5) = y(14); taxa{5} = 'birds';
      x(6) = y(15); taxa{6} = 'mammals';
   case 7
      TAXA = {'Radiata'; 'Protostomata'; 'Echinodermata'; 'Cephalochordata'; 'Tunicata'; 'Myxini'; 'Agnatha'; 'Chondrichthyes'; 'Actinopterygii'; 'Actinistia'; 'Dipnoi'; 'Amphibia'; 'Sauropsida'; 'Aves'; 'Mammalia'};    
      n = length(TAXA); y = zeros(n, 1);
      for i = 1:n
        y(i) = length(select(TAXA{i}));
      end
      x(1:2) = y(1:2); taxa(1:2) = TAXA(1:2);
      x(3) = sum(y(3:5));  taxa{3} = 'acraniate deut';
      x(4) = sum(y(6:11)); taxa{4} = 'fish';
      x(5) = sum(y(12:13)) - y(14); taxa{5} = 'amph + rept';
      x(6) = y(14); taxa{6} = 'birds';
      x(7) = y(15); taxa{7} = 'mammals';
    case 8
      TAXA = {'Radiata'; 'Chaetognatha'; 'Spiralia'; 'Ecdysozoa'; 'Echinodermata'; 'Cephalochordata'; 'Tunicata'; 'Myxini'; 'Agnatha'; 'Chondrichthyes'; 'Actinopterygii'; 'Actinistia'; 'Dipnoi'; 'Amphibia'; 'Sauropsida'; 'Aves'; 'Mammalia'};    
      n = length(TAXA); y = zeros(n, 1);
      for i = 1:n
        y(i) = length(select(TAXA{i}));
      end
      x(1) = sum(y(1:2)); taxa{1} = 'rad + chaeto';
      x(2:3) = y(3:4); taxa(2:3) = TAXA(3:4);
      x(4) = sum(y(5:7));  taxa{4} = 'acraniate deut';
      x(5) = sum(y(8:13)); taxa{5} = 'fish';
      x(6) = sum(y(14:15)) - y(16); taxa{6} = 'amph + rept';
      x(7) = y(16); taxa{7} = 'birds';
      x(8) = y(17); taxa{8} = 'mammals';
    otherwise
      taxa = {'Radiata'; 'Chaetognatha'; 'Gnathifera'; 'Platytrochozoa'; 'Ecdysozoa'; 'Deuterostomata'};    
      n = length(taxa); x = zeros(n, 1);
      for i = 1:n
        x(i) = length(select(taxa{i}));
      end
  end
  
  pie3s(x, 'Bevel', 'Elliptical', 'Labels', taxa);

  if ~(sum(x) == length(select('Animalia')))
     fprintf('Warning: taxa specification needs updating')
  end
end

