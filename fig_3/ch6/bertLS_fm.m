function [LF LM SF SM] = bertLS_fm(p, aLF, aLM, aSF, aSM)
  %% e = 1; LT = 0; 
  global kM v g ha sG
  %% unpack parameters
  Lb = p(1); gF = p(2); gM = p(3); kM = p(4);
  v = p(5); ha = p(6); sG = p(7);

  LmF = v/ kM/ gF; LmM = v/ kM/ gM;
  rBF = 1/ (3/ kM + 3 * LmF/ v); % von Bert growth rate Eq (3.22) {95}
  rBM = 1/ (3/ kM + 3 * LmM/ v); % von Bert growth rate Eq (3.22) {95}
  LF = LmF - (LmF - Lb) * exp(- rBF * aLF(:,1)); % Eq (3.20) {95}
  LM = LmM - (LmM - Lb) * exp(- rBM * aLM(:,1)); % Eq (3.20) {95}

  aF = aSF(:,1); g = gF;
  [a LS] = ode23('dbertLS_fm', [-1e-6; aF], [Lb; .92; 0; 0]);
  SF = LS(:,2); SF(1) = [];

  aM = aSM(:,1); g = gM;
  [a LS] = ode23('dbertLS', [-1e-6; aM], [Lb; 1; 0; 0]);
  SM = LS(:,2); SM(1) = [];
