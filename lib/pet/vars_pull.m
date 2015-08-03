function vars_pull(s)
%% This is great111!
    for n = fieldnames(s)'
        name = n{1};
        value = s.(name);
        assignin('caller',name,value);
    end
    
end    