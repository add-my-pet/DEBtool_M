%% vars_pull

function vars_pull(s)
% created 2015/08/03

    for n = fieldnames(s)'
        name = n{1};
        value = s.(name);
        assignin('caller',name,value);
    end
    
end    
