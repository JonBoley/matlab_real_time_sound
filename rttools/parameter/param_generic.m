


% parameter_generic has one string field
classdef param_generic < parameter
  
%   Copyright 2019 Stefan Bleeck, University of Southampton
    methods
        function param=param_generic(text,val,varargin)
            param@parameter(text,val,varargin{:});
        end
        
        
        % draw puts in on the screen. The base class put's on a text and
        function draw(param,parentpanel,x,y)
            draw@parameter(param,parentpanel,x,y);
            val=getvalue(param);
            callbackfct=@(src,event)callback_change_value(param);
            [~,elem2]=getelementpositions(param,parentpanel,x,y);
            
            ef=uieditfield(parentpanel);      %  edit box
            ef.BackgroundColor=[1 1 1];
            ef.Position=[elem2.x elem2.y elem2.w elem2.h];
            ef.ValueChangedFcn=callbackfct;
            ef.Value=string(val);
            ef.FontSize=14;
            ef.HorizontalAlignment='right';
            param.hand(2) = ef;
        end        
    end
end
