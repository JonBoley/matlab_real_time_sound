%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef rt_sai_boxcutting < rt_sai_ps
    
    properties
        
        
    end
    
    
    methods
        function obj=rt_sai_boxcutting(parent,varargin)  %init
            obj@rt_sai_ps(parent,varargin{:});
            g=obj.p;
            
            obj.fullname='Boxcutting on the Stabilized auditory image';
            pre_init(obj);  % add the parameter gui
            obj.p=g;
            
            setvalue(obj.p,'numberChannels',96);
            setvalue(obj.p,'highest_frequency',8000);
            setvalue(obj.p,'lowest_frequency',80);
            
        end
        
        
        function post_init(obj) % called the second times around
            post_init@rt_sai_ps(obj);
        end
        
        
        % calculate the dual profile!
        function vec=calculate(obj,sig)
            calculate@rt_sai_ps(obj,sig);      % call superclass to calculate stabilised auditory image in this frame
            
            sai=obj.sai;
            basesize=[16,32];
            
            % boxcutting along:
            % https://www.acousticscale.org/wiki/index.php/Auditory-Based_Processing_of_Communication_Sounds.1.html#.60Box_cutting.27_and_sparse_coding
           
            
%             figure(3),clf,hold on
%             imagesc(sai);
%             axis([1 96 1 561]);
            vec=zeros(64,48);

            nrb=0;
            for scalex=1:3  % smallest box is
                for scaley=1:3
                    for shiftx=0:0.5:2
                        for shifty=0:0.5:2
                            ret=get_boxes(sai,scalex,shiftx,scaley,shifty);
                            if ret(1)+ret(3)-1<=size(sai,1) && ret(2)+ret(4)-1<=size(sai,2)
%                                 rectangle('Position',ret,'FaceColor',[rand rand rand]);
                                nrb=nrb+1;
                                smallb=boxdownsample(sai,ret,basesize);
                                vec(nrb,:)=[sum(smallb,1) sum(smallb,2)'];   % build the feature vector as the marginals
%                                 imagesc(smallb)
                            end
                        end
                    end
                end
            end
        end
    end
end

% give me back a downsampled box of the right size
function ret=get_boxes(sai,scalex,shiftx,scaley,shifty)
x_box_null=floor(size(sai,1)/3);  % this is what they used 32
y_box_null=floor(size(sai,2)/3);  % this is what they used 16
x1=1+shiftx*scalex*x_box_null;
y1=1+shifty*scaley*y_box_null;
x2=scalex*x_box_null;
y2=scaley*y_box_null;
ret=[x1 y1 x2 y2];
end

% take one rectangle and reduce it to the base
function small_box=boxdownsample(sai,ret,basesize)
xr=ret(4);
yr=ret(3);
psai=sai(round(ret(1)):round(ret(1)+ret(3)-1),round(ret(2)):round(ret(2)+ret(4)-1));

xs=xr/basesize(2);
ys=yr/basesize(1);
[Xq,Yq]=meshgrid(1:xs:xr,1:ys:yr);

small_box=interp2(psai,Xq,Yq);
end
