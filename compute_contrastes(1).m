%output example:
% {        Y = Si Altos*PM + No Altos*PM + Si Bajo*PM + No Bajos*PM
%  {'jugadorbien>jugadormal' [1 1 -1 -1 0 0 0 0 0 0 1 1 -1 -1 0 0 0 0 0 0]}
%}
function [contrastes] = compute_contrastes(nro_condiciones, whole_task)

%%% Armo contraste para cada trial
condsXsesion = str2double(string(nro_condiciones));

startCondsSes2 = condsXsesion(1) + 1;
startCondsSes3 = condsXsesion(1) + condsXsesion(2) + 1;
startCondsSes4 = condsXsesion(1) + condsXsesion(2) + condsXsesion(3) + 1;

endCondsSes1 = condsXsesion(1);
endCondsSes2 = condsXsesion(1) + condsXsesion(2);
endCondsSes3 = condsXsesion(1) + condsXsesion(2) + condsXsesion(3);
endCondsSes4 = condsXsesion(1) + condsXsesion(2) + condsXsesion(3) +condsXsesion(4);

condsTotales = sum(condsXsesion);

contrast_matrix = eye(condsTotales);

contrast_matrix_per_trial = [contrast_matrix(1:condsTotales , 1:endCondsSes1) zeros(condsTotales,6) contrast_matrix(1:condsTotales , startCondsSes2:endCondsSes2) zeros(condsTotales,6) contrast_matrix(1:condsTotales , startCondsSes3:endCondsSes3) zeros(condsTotales,6) contrast_matrix(1:condsTotales , startCondsSes4:endCondsSes4) zeros(condsTotales,6)];

%%% Armo contraste para feedbacks

ceros_mov = [0 0 0 0 0 0];

condiciones_sesion = {
    {'jugb_vs_jugm'                  [1 1 -1 -1]}               %5
    {'cojb_vs_cojm'                  [1 -1 1 -1]}               %6
    {'interaccion'                   [1 -1 -1 1]}               %7
    {'bb_vs_bm'                      [1 -1 0 0]}                %8
    {'bb_vs_mb'                      [1 0 -1 0]}                %9
    {'bb_vs_mm'                      [1 0 0 -1]}                %10
    {'bm_vs_mb'                      [0 1 -1 0]}                %11
    {'bm_vs_mm'                      [0 1 0 -1]}                %12
    {'mb_vs_mm'                      [0 0 1 -1]}                %13
};

condsSes1 = condsXsesion(1);
condsSes2 = condsXsesion(2);
condsSes3 = condsXsesion(3);
condsSes4 = condsXsesion(4);

for index=1:length(condiciones_sesion)
    
  contrastes_sesion = condiciones_sesion{index}{2};
    
  sesion_1 = zeros(1, condsSes1);
  sesion_1(condsSes1-3:condsSes1) = contrastes_sesion;
  
  sesion_2 = zeros(1, condsSes2);
  sesion_2(condsSes2-3:condsSes2) = contrastes_sesion;
  
  sesion_3 = zeros(1, condsSes3);
  sesion_3(condsSes3-3: condsSes3) = contrastes_sesion;
  
  sesion_4 = zeros(1, condsSes4);
  sesion_4(condsSes4-3: condsSes4) = contrastes_sesion;
  
  contrastes_feedback(index,:) = ([sesion_1 ceros_mov sesion_2 ceros_mov sesion_3 ceros_mov sesion_4 ceros_mov]);
end


%%% Armo contraste para toma de decisiones global

ceros_feedback = [0 0 0 0];

decisionesS1 = whole_task{1,1}.cat_elegida;
decisionesS1_u = string(decisionesS1)=="upward";
decisionesS1_d = string(decisionesS1)=="downward";

decisionesS2 = whole_task{1,2}.cat_elegida;
decisionesS2_u = string(decisionesS2)=="upward";
decisionesS2_d = string(decisionesS2)=="downward";

decisionesS3 = whole_task{1,3}.cat_elegida;
decisionesS3_u = string(decisionesS3)=="upward";
decisionesS3_d = string(decisionesS3)=="downward";

decisionesS4 = whole_task{1,4}.cat_elegida;
decisionesS4_u = string(decisionesS4)=="upward";
decisionesS4_d = string(decisionesS4)=="downward";

decision_con = [decisionesS1_u' ceros_feedback ceros_mov decisionesS2_u' ceros_feedback ceros_mov decisionesS3_u' ceros_feedback ceros_mov decisionesS4_u' ceros_feedback ceros_mov];

total_downward = sum(decisionesS1_d) + sum(decisionesS2_d) + sum(decisionesS3_d) + sum(decisionesS4_d);

if total_downward ~= 0
    decision_con(2,:) = ([decisionesS1_d' ceros_feedback ceros_mov decisionesS2_d' ceros_feedback ceros_mov decisionesS3_d' ceros_feedback ceros_mov decisionesS4_d' ceros_feedback ceros_mov]);
end

contrastes = vertcat(contrast_matrix_per_trial, contrastes_feedback, decision_con);
end