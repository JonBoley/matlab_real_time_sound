


classdef rt_spectrum_narrow < rt_spectrum
    
    properties
        
    end
    
    methods
        function obj=rt_spectrum_narrow(parent,varargin)  %init
            obj@rt_spectrum(parent,varargin{:});
            obj.fullname='narrowband Spectrogram';
            obj.show=1; % please do show me!
        end
        
        function post_init(obj)
            setvalue(obj.p,'WindowLengthbins',512);
            setvalue(obj.p,'Overlap',256);
            setvalue(obj.p,'NumberFFTbins','512');
            setvalue(obj.p,'WindowFunction','hann');
            post_init@rt_spectrum(obj);
        end
    end
end