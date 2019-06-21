%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


classdef rt_bmm < rt_visualizer
    
    properties
        viz_buffer;
        xlab;
        ylab;
        fbank;
    end
    
    methods
        function obj=rt_bmm(parent,varargin)  %init
            obj@rt_visualizer(parent,varargin);
            obj.fullname='Basilar membrane motion';
            pre_init(obj);  % add the parameter gui
            
            pars = inputParser;
            pars.KeepUnmatched=true;
            addParameter(pars,'numberChannels',50);
            addParameter(pars,'lowest_frequency',100);
            addParameter(pars,'highest_frequency',6000);
            addParameter(pars,'autoscale',0);
            addParameter(pars,'zoom',1);
            parse(pars,varargin{:});
            
            add(obj.p,param_number('numberChannels',pars.Results.numberChannels));
            add(obj.p,param_number('lowest_frequency',pars.Results.lowest_frequency));
            add(obj.p,param_number('highest_frequency',pars.Results.highest_frequency));
            add(obj.p,param_checkbox('autoscale',pars.Results.autoscale));
            add(obj.p,param_float_slider('zoom',pars.Results.zoom,'minvalue',1,'maxvalue',100,'scale','log'));
            
            s='the basilar membrane simulator simulates how the BM moves in response to sound';
            s=[s,'gammatoneFilterBank decomposes a signal by passing it through a bank of gammatone filters equally spaced on the ERB scale. '];
            s=[s,'Gammatone filter banks were designed to model the human auditory system.'];
            s=[s,'the code is a wrapper of the MATLAB function gammatoneFilterBank'];
            s=[s,'which in turn implements the Malcom Slaney version of a 4th order gammatone filter'];
            s=[s,'[1] Slaney, Malcolm. "An Efficient Implementation of the Patterson-Holdworth Auditory Filter Bank." Apple Computer Technical Report 35, 1993.'];
            s=[s,'[2] Patterson, R.d., K. Robinson, J. Holdsworth, D. Mckeown, C. Zhang, and M. Allerhand. "Complex Sounds and Auditory Images." Auditory Physiology and Perception. 1992, pp. 429?446.'];
            obj.descriptor=s;
            
        end
        
        function post_init(obj) % called the second times around
            post_init@rt_visualizer(obj); % create my axes
            ax=obj.viz_axes;
            
            num_channels=getvalue(obj.p,'numberChannels');
            lowfre=getvalue(obj.p,'lowest_frequency');
            highfre=getvalue(obj.p,'highest_frequency');
            
            
            sample_rate=obj.parent.SampleRate;
            
            obj.fbank=gammatoneFilterBank([lowfre highfre],num_channels,sample_rate);
            
            obj.viz_buffer=circbuf(round(obj.parent.PlotWidth*obj.parent.SampleRate),num_channels);
            
            imagesc(get(obj.viz_buffer)','parent',ax);
            set(ax,'ylim',[1 num_channels]);
            set(ax,'xlim',[1 getlength(obj.viz_buffer)]);
            
            fs=obj.fbank.getCenterFrequencies;
            
            obj.ylab=get(ax,'YTickLabel');
            for i=1:length(obj.ylab)
                nr=str2double(obj.ylab{i});
                l=fs(nr);
                ll{i}=sprintf('%2.2f',l/1000);
            end
            obj.ylab=ll;%(end:-1:1);
            xlabel(ax,'time (sec)')
            ylabel(ax,'frequency (kHz)')
            set(ax,'YTickLabel',obj.ylab);
            
            xt=get(ax,'xtick');
            xtt=xt/getlength(obj.viz_buffer)*obj.parent.PlotWidth;
            for i=1:length(xt)
                obj.xlab{i}=sprintf('%2.1f',xtt(i));
            end
            
            % create an interesting color map: from red to white and then to blue
            nr_colors=100;
            c=colormap(ax);
            c(:,:)=1; % first make all white
            c(1:nr_colors/2,1)=linspace(0,1,nr_colors/2);
            c(1:nr_colors/2,2)=linspace(0,1,nr_colors/2);
            c(nr_colors/2+1:nr_colors,2)=linspace(1,0,nr_colors/2);
            c(nr_colors/2+1:nr_colors,3)=linspace(1,0,nr_colors/2);
            colormap(ax,c);
            
            view(ax,0,270);
            set(ax,'CLim',[0 nr_colors])
            
            set(ax,'xticklabel',obj.xlab)
            set(ax,'yticklabel',obj.ylab)
            
            
        end
        
        function plot(obj,sig)
            
            if has_changed(obj.p)
                p1=getparameter(obj.p,'numberChannels');
                p2=getparameter(obj.p,'lowest_frequency');
                p3=getparameter(obj.p,'highest_frequency');
                if has_changed(p1) || has_changed(p2)|| has_changed(p3)
                    post_init(obj);
                    set_changed_status(obj.p,0);
                end
            end
            
            ax=obj.viz_axes;
            specbuf=obj.viz_buffer;
            
            bmm=step(obj.fbank,sig);
            specbuf=push(specbuf,bmm);
            
            vals=get(specbuf)';
            z=getvalue(obj.p,'zoom');
            if getvalue(obj.p,'autoscale')
                v1=min(min(vals));
                v2=max(max(vals));
%                 vals=vals/(v2-v1)));
                imagesc(vals*100/(v2-v1),'parent',ax);
            else
                random_calibrtion_value=100;
                vals=vals.*random_calibrtion_value;
                vals=vals.*z;
                vals=vals+50;
                image(vals,'parent',ax);
            end
        end
    end
end