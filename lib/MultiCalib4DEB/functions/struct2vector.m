function [vec, meanVec] = struct2vector(struct, fieldNames)
  vec = []; meanVec = [];
  for i = 1:size(fieldNames, 1)
    fieldsInCells = textscan(fieldNames{i},'%s','Delimiter','.');
    aux = getfield(struct, fieldsInCells{1}{:});
    vec = [vec; aux(:)];
    meanVec = [meanVec; ones(length(aux(:)), 1) * mean(aux(:))];
  end
end

