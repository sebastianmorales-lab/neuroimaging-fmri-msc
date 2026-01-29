function [output] = compute_contrastes_parametric_2(choice_individual_blocks, outcomes_individual_b, outcomes_individual_m, repMB, repIndB, repIndM, posicionMB, posicionIndB, posicionIndM)

CONTRASTE_LABEL = 1;
CONTRASTE_VALUES = 2;

n_zeros = 6;
n_sessions = 4;

zeros_block = zeros(1, n_zeros);

contrastes = {
   {'solo_onset'     [1  0  0  0  0  0  0  0  0]}                            %  1
   {'rival'          [0  1  0  0  0  0  0  0  0]}                            %  2
   {'pago'           [0  0  1  0  0  0  0  0  0]}                            %  3
   {'jugB>jugM'      [0  0  0  1/4  1/4 -1/4 -1/4  1/repIndB -1/repIndM]}    %  4
   {'cJB>cJM'        [0  0  0  1  1 -1 -1  0  0]}                            %  5
   {'cojB>cojM'      [0  0  0  1 -1  1 -1  0  0]}                            %  6
   {'BB>BM'          [0  0  0  1 -1  0  0  0  0]}                            %  7
   {'BB>MB'          [0  0  0  1  0 -1  0  0  0]}                            %  8
   {'BB>MM'          [0  0  0  1  0  0 -1  0  0]}                            %  9
   {'BM>MB'          [0  0  0  0  1 -1  0  0  0]}                            %  10
   {'BM>MM'          [0  0  0  0  1  0 -1  0  0]}                            %  11
   {'MB>MM'          [0  0  0  0  0  1 -1  0  0]}                            %  12
   {'indB>indM'      [0  0  0  0  0  0  0  1/repIndB -1/repIndM]}                            %  13
   {'interaccion'    [0  0  0  1 -1 -1  1  0  0]}                            %  14
   {'solo_bb'        [0  0  0  1  0  0  0  0  0]}                            %  15
   {'solo_bm'        [0  0  0  0  1  0  0  0  0]}                            %  16
   {'solo_mb'        [0  0  0  0  0  1  0  0  0]}                            %  17
   {'solo_mm'        [0  0  0  0  0  0  1  0  0]}                            %  18
   {'solo_ind_b'     [0  0  0  0  0  0  0  1/repIndB  0]}                    %  19
   {'solo_ind_m'     [0  0  0  0  0  0  0  0  1/repIndM]}                    %  20
   
};

filtered = {};

for i_contraste =1:length(contrastes)
  contraste_values = [];

  for i_session =1:n_sessions
%     individuals   = height(choice_individual_blocks{i_session});
%     individuals_b = height(outcomes_individual_b{i_session});
%     individuals_m = height(outcomes_individual_m{i_session});
% 
    contrast_block = contrastes{i_contraste}{CONTRASTE_VALUES};
    
%     if posicionMB(i_session)~=0
%         contrast_block(posicionMB(i_session)) = [];
%     end
    
    if posicionIndB(i_session) ~= 0
       contrast_block(posicionIndB(i_session)) = [];
    end

    if posicionIndM(i_session) ~= 0
        contrast_block(posicionIndM(i_session)) = [];
     end
% 
%     if individuals
%       contrast_block(end+1) = 0;
%     end
% 
%     if individuals_b
%       contrast_block(end+1) = 0;
%     end
% 
%     if individuals_m
%       contrast_block(end+1) = 0;
%     end
    
    contraste_values = [contraste_values contrast_block zeros_block];
  end

  name    = contrastes{i_contraste}{CONTRASTE_LABEL};
  
  if repIndB==0
    if strcmp(name, 'solo_ind_b')
        continue
    elseif strcmp(name, 'indB>indM')
        continue
    end
  end
  
  if repIndM==0
    if strcmp(name, 'solo_ind_m')
        continue
    elseif strcmp(name, 'indB>indM')
        continue
    end
  end
  
  filtered{end+1} = {name contraste_values};
end

output = {filtered contrastes};



