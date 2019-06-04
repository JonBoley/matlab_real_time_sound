


classdef rt_spectrum_wide < rt_spectrum
    
    properties
        
    end
    
    methods
        function obj=rt_spectrum_wide(parent,varargin)  %init
            obj@rt_spectrum(parent,varargin{:});
            obj.fullname='wideband Spectrogram';
            obj.show=1; % please do show me!
        end
        
        function obj=post_init(obj)
            setvalue(obj.p,'WindowLengthbins',256);
            setvalue(obj.p,'Overlap',16);
            setvalue(obj.p,'NumberFFTbins','256');
            setvalue(obj.p,'WindowFunction','hann');
            post_init@rt_spectrum(obj);
        end
    end
end