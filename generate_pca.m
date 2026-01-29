
%% calcular los componentes principales
%% generar_pca.m
% Script interactivo de PCA que pide la matriz `data` por terminal.

% 1) Petición de ingreso interactivo
data = input('Ingrese la matriz de datos (p.ej. [1 2 3;4 5 6]): ');

% 2) Validación
assert(isnumeric(data) && ~isempty(data), ...
    'Error: "data" debe ser un arreglo numérico no vacío.');

% 3) Estandarización (z-score)
zdata = (data - mean(data,1)) ./ std(data,[],1);

% 4) PCA
[coeff, score, latent, tsquared, explained, mu] = pca(zdata);

% 5) Mostrar resultados
disp('Varianza explicada (%) por componente:');
disp(explained);

% 6) Gráficos
%   – PC1 vs PC2 (si existen dos componentes)
if size(score,2) >= 2
    figure
    scatter(score(:,1), score(:,2), 50, 'filled')
    xlabel('PC1'); ylabel('PC2')
    title('PCA: PC1 vs PC2')
    grid on
else
    warning('Sólo una componente disponible; no hay PC2 para graficar.')
end

%   – Scree plot
figure
plot(explained, '-o')
title('Scree Plot')
xlabel('Componente')
ylabel('% Varianza explicada')
grid on

%   – Varianza acumulada
figure
plot(cumsum(explained), '-o')
title('Varianza acumulada')
xlabel('Componente')
ylabel('% Varianza acumulada')
grid on


%  _ Mapa de calor de las cargas(loadings)
figure
imagesc(coeff)
colorbar
xlabel('Componente principal')
ylabel('Variable')
title('Heatmap de loadings')

%  _ Scatter 3D de PC1–PC2–PC3
if size(score,2)>=3
  figure
  scatter3(score(:,1),score(:,2),score(:,3),...
           36,score(:,3),'filled')
  xlabel('PC1'); ylabel('PC2'); zlabel('PC3')
  title('Scatter 3D PC1–PC2–PC3')
  colorbar
  grid on
end
% _ Bar chart de contribuciones
pc = 1;  % el PC que quieras analizar
figure
bar(coeff(:,pc))
xticks(1:size(coeff,1))
xticklabels({'V1','V2','V3','V4','V5'})
xlabel('Variable')
ylabel('Loading')
title(sprintf('Contribución a PC%d',pc))
grid on

% _ Circulo de correlaciones
theta = linspace(0,2*pi,100);
figure; plot(cos(theta),sin(theta),'k--'); hold on
for i=1:size(coeff,1)
  x = coeff(i,1); y = coeff(i,2);
  text(x,y,['  V' num2str(i)],'FontSize',12)
  plot([0 x],[0 y],'LineWidth',1.2)
end
axis equal; grid on
title('Círculo de correlación PC1–PC2')

