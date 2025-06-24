%% convert_data_to_standard_units
% Converts zero-variate data to standard DEB units

function sudata = convert_data_to_standard_units(data, txtData)
% created 2025/06/23 by Diogo F. Oliveira

%% Syntax
% [par, metaPar, txtPar] = <../init_DEBInitNet.m *init_DEBInitNet*> (data, auxData, metaData)

%% Description
% Converts data to standard DEB units (g, cm, d, mol, K) using MATLAB functions from the Symbolic
% Math Toolbox. 
%
% Input
%
% * data: structure with values of data
% * txtData: structure with information on the data (used to convert data to standard units)
%
% Output
%
% * sudata: structure with values of data converted to standard units

%% Remarks
% Requires the Symbolic Math Toolbox to be used
%
% Only zero-variate data is converted to standard units, since this function is meant to
% preprocess input data for the DEBMLInit initialization methods.

% Create the DEB unit system
u = symunit;
debUnits = newUnitSystem('DEBUnits', [u.cm, u.g, u.mol, u.d, u.K]);

% Convert data to DEB unit system
dataFields = fieldnames(data);
sudata = data;
for d=1:numel(dataFields)
    datasetName = dataFields{d};
    value = data.(datasetName);
    origUnit = txtData.units.(datasetName);
    % Skip pseudo data struct
    if isstruct(value)
        continue
    end
    % Convert zero variate data
    if size(data.(datasetName), 1) == 1
        sudata.(datasetName) = convertMeasurementUnits(datasetName, value, origUnit, debUnits);
    end
end
end



function convertedValue = convertMeasurementUnits(datasetName, value, origUnit, debUnits)

% EDGE CASES: Correctly format measurements in micro units
if (length(origUnit) > 1) && (strcmp(origUnit(1:2),'mu'))
    origUnit = origUnit(2:end);
elseif (length(origUnit) > 6) && strcmp(origUnit(1:6), 'micro ')
    origUnit = ['u' origUnit(7:end)];
end
% Replace # with '1'
origUnit = strrep(origUnit, '#', '1');
% Replace '-' with '1' (dimensionless)
origUnit = strrep(origUnit, '-', '1');
% Express text as symbolic unit
try
    symOrigUnit = str2symunit(origUnit);
catch ME
    fprintf(ME.message)
    % Assume value is in target unit (assume that there has been a mistake in defining the unit in the mydata.m file)
    convertedValue = value;
    fprintf('Dataset %s in unit ''%s'' could not be converted to standard units. Assuming standard unit. \n', datasetName, origUnit)
    return
end

% Convert units
measurement = value * symOrigUnit;
convertedMeasurement = unitConvert(measurement, debUnits);
convertedValue = double(separateUnits(convertedMeasurement));

end