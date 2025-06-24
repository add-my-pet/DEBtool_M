%% DEBInitNet
% Neural network that can predict DEB model parameters based on data and metadata.

classdef DEBInitNet < handle
    % created 2025/06/21 by Diogo Oliveira

    %% Usage
    % The neural network is instatiated via the constructor method:
    %   nn = DEBInitNet(modelStructureFile);
    % The variable modelStructureFile contains the network parameters. It is the following file:
    %   modelStructureFile = 'deb_init_net.mat';
    % To predict the parameters from an input vector call the predict method of the object:
    %   yPred = nn.predict(inputData)
    %
    %% Description
    % DEBInitNet is a neural network that takes as input some zero-variate datasets as well as
    % metadata takes from the metaData struct. 
    % The structure of the input is described in <fetch_input_for_DEBInitNet.html *fetch_input_for_DEBInitNet*>.
    % The neural network does not output model parameters directly, but instead functions of them in 
    % order to enforce parameter constraints. It has the following shape:
    %       [p_M] 1-kap v s_p/s_M^3 s_H^b/p s_H^b/j s_H^j/p E_Hp k_J s_M 
    %
    % The model first transforms the input data with log-scaling and standardization. Then, the 
    % input is passed to the shared hidden layers. Then, the output of the shared hidden layers is 
    % given to a series of parameter specific hidden layers, which compute the output. Some outputs 
    % are constrained to be smaller than 1 directly in model scale. Finally, the output is 
    % transformed from model scale to parameter scale by inverting log-scaling and standardization. 
    % All hidden layers have ReLU activation functions. 
    % The scaling and model outputs ensure the parameter set respects all constraints except reaching 
    % birth and metamorphosis.
    % 
    %% Remarks
    % This class is used in the function <init_DEBInitNet.html *init_DEBInitNet*>. If you wish to
    % get initial parameters for your DEB model, call that function instead of using this object.
    %
    % For the model description check Oliveira et. al (2025) (in prep.)
    %
    % The neural network was trained on std, stx, stf, and abj species. It is not intented to be
    % used for other model structures
    %
    % The model is not guaranteed to produce feasible parameter sets since the constraints at birth
    % and metamorphosis are not directly enforced. However, results show it is quite reliable at
    % doing so, as the feasibility rate is greater than 99% (tested on >2300 species). 

    properties (Constant)
        EPSILON = 1e-6;
    end
    properties
        nInputs            % the dimension of the input vector
        nOutputs           % the dimension of the output vector
        useSkipConnection  % whether to concatenate the input vector to the input of the par layers
        sharedWeights      % cell array of weight matrices for shared layers
        sharedBiases       % cell array of bias vectors for shared layers
        parWeights         % 2D cell array (param x layer) of weight matrices
        parBiases          % 2D cell array (param x layer) of bias vectors
        boundedColIdx      % indices of outputs to clamp in log space
        upperBounds        % standardized log-scale upper bounds vector (loaded)
        % Scaling parameters
        inputMean          % vector of means for input standardization (for scaled inputs)
        inputStd           % vector of std devs for input standardization
        outputMean         % vector of means for output standardization
        outputStd          % vector of std devs for output standardization
        % Column indices for transforms (loaded directly from file)
        inputLogIdx        % indices of inputs to apply log
        inputScaleIdx      % indices of inputs to standardize (corresponding to inputMean/std)
        outputLogIdx       % indices of outputs to apply inverse log
        outputScaleIdx     % indices of outputs to destandardize (corresponding to outputMean/std)
    end

    methods
        function obj = DEBInitNet(modelStructureFile)
            % Constructor method. Loads model structure from .mat file 
            %   Input
            %
            %   * modelStructureFile: string path to .mat file containing network parameters
            %       The .mat file must contain network the following variables:
            %           sharedWeights, sharedBiases, parWeights, parBiases,
            %           useSkipConnection,
            %           inputMean, inputStd, outputMean, outputStd,
            %           inputLogIdx, inputScaleIdx, outputLogIdx, outputScaleIdx,
            %           boundedColIdx, upperBounds
            %       The descriptions of each variable are above.
            %   
            %   Output
            %   
            %   * obj: the DEBInitNet object
            if nargin < 1 || isempty(modelStructureFile)
                error('A .mat file containing the model structure must be provided.');
            end
            data = load(modelStructureFile);

            % Network parameters
            obj.sharedWeights     = data.sharedWeights;
            obj.sharedBiases      = data.sharedBiases;
            obj.parWeights        = data.parWeights;
            obj.parBiases         = data.parBiases;
            obj.useSkipConnection = data.useSkipConnection;

            % Scaler parameters
            obj.inputMean   = data.inputMean;
            obj.inputStd    = data.inputStd;
            obj.outputMean  = data.outputMean;
            obj.outputStd   = data.outputStd;

            % Column indices for transforms
            obj.inputLogIdx    = data.inputLogIdx;
            obj.inputScaleIdx  = data.inputScaleIdx;
            obj.outputLogIdx   = data.outputLogIdx;
            obj.outputScaleIdx = data.outputScaleIdx;

            % Loaded bounded clamp configuration
            obj.boundedColIdx = data.boundedColIdx;
            obj.upperBounds   = data.upperBounds;

            % Dimensions based on model structure
            obj.nInputs  = size(obj.sharedWeights{1}, 2);
            obj.nOutputs = size(obj.parWeights, 1);
        end

        function yPred = predict(obj, x)
            % Predicts DEB model parameters based on data and metadata. Some columns are first
            % log-scaled and then standardized. The neural network predicts the parameters, which
            % are then unscaled. The output of the neural network is not directly the parameters, 
            % they are transformed into parameter values in init <init_DEBInitNet.html *init_DEBInitNet*> 
            % 
            % Inputs
            %   * x: a column vector of inputs (nInputs x 1). 
            %
            % Outputs
            %   * yPred: a column vector of outputs (nOutputs x 1). 
            %
            assert(isvector(x) && numel(x)==obj.nInputs, 'Input must be a column vector of length nInputs');

            % Transform input selectively
            xModelScale = obj.transformInput(x);

            % Shared layers
            out = xModelScale;
            for i = 1:numel(obj.sharedWeights)
                out = obj.relu(obj.sharedWeights{i} * out + obj.sharedBiases{i});
            end

            % Skip connection
            if obj.useSkipConnection
                inPar = [out; xModelScale];
            else
                inPar = out;
            end

            % Parameter-specific layers
            yModelScale = zeros(obj.nOutputs,1);
            numLayers = size(obj.parWeights, 2);
            for o = 1:obj.nOutputs
                tmp = inPar;
                for l = 1:numLayers
                    tmp = obj.parWeights{o, l} * tmp + obj.parBiases{o, l};
                    if l < numLayers
                        tmp = obj.relu(tmp);
                    end
                end
                yModelScale(o) = tmp;
            end

            % Clamp log-scale outputs
            if ~isempty(obj.boundedColIdx)
                raw = yModelScale(obj.boundedColIdx);
                yModelScale(obj.boundedColIdx) = obj.upperBounds + log(obj.sigmoid(raw)) - obj.EPSILON;
            end

            % Inverse transform outputs selectively
            yPred = obj.inverseTransformOutput(yModelScale);
        end
    end

    methods (Access = private)
        function xModelScale = transformInput(obj, x)
            % Transforms input data to model scale. Selectively applies log and standardization to 
            % input vector based on inputLogIdx and inputScaledIdx.
            %
            % Inputs
            %   * x: a column vector of inputs (nInputs x 1). 
            % Outputs
            %   * xModelScale: a column vector of input data in model scale (nInputs x 1).
            xModelScale = x;
            if ~isempty(obj.inputLogIdx)
                xModelScale(obj.inputLogIdx) = log(xModelScale(obj.inputLogIdx));
            end
            if ~isempty(obj.inputScaleIdx)
                % inputMean/std correspond exactly to these indices
                xModelScale(obj.inputScaleIdx) = (xModelScale(obj.inputScaleIdx) - obj.inputMean) ./ obj.inputStd;
            end
        end

        function yParScale = inverseTransformOutput(obj, yModelScale)
            % Converts the output of the model to parameter scale. Selectively reverses log scaling
            % and standardization based on outputLogIdx and outputScaleIdx.
            %
            % Inputs
            %   * yModelScale: a column vector of outputs in model scale(nOutputs x 1). 
            % Outputs
            %   * yParScale: a column vector of outputs in parameter scale (nOutputs x 1).
            yParScale = yModelScale;
            if ~isempty(obj.outputScaleIdx)
                yParScale(obj.outputScaleIdx) = yParScale(obj.outputScaleIdx) .* obj.outputStd + obj.outputMean;
            end
            if ~isempty(obj.outputLogIdx)
                yParScale(obj.outputLogIdx) = exp(yParScale(obj.outputLogIdx));
            end
        end
    end

    methods (Static, Access=private)
        function s = sigmoid(x)
            % Applies the sigmoid function element-wise.
            s = 1 ./ (1 + exp(-x));
        end

        function y = relu(x)
            % Applies the ReLU activation function.
            y = max(x, 0);
        end
    end
end
