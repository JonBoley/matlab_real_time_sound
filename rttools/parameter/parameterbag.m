%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)

classdef parameterbag < handle
    properties
        name;
        cont;
        guihandle=-1; % no screen representation yet
        items;
        parent;
        listener=[]; % can be an object that respods to a butto press,e tc
    end
    
    methods
        function pbag=parameterbag(name,parent)
            if nargin <2
                parent=0;
            end
            if nargin<1
                name='parameterbag class';
            end
            pbag.name=name;
            pbag.items=containers.Map;
            pbag.parent=parent; % no parent yet
        end
        
        function add(pbag,param)
            pbag.items(param.text)=param;
            set_parent(param,pbag);
            param.panelnr=length(pbag.items);
        end
        
        function set_listener(pbag,obj)
            pbag.listener=obj;
        end
        
        function disp(pbag)   % display the pbag
            fprintf('''%s'': parameterbag with %d entries:\n',pbag.name,length(pbag.items));
            k=keys(pbag.items);
            for i=1:length(pbag.items)
                disp(pbag.items(k{i}));
            end
        end
        
        function p=getparameter(pbag,str)
            p=[];
            k=keys(pbag.items);
            for i=1:length(pbag.items)
                if isequal(pbag.items(k{i}).text,str)
                    p=pbag.items(k{i});
                    return
                end
            end
        end
        
        function v=getvalue(pbag,text,wunit)  % get the value of this param
            if ~isKey(pbag.items,text)
                error('''%s'' is not a parameter in the parameter bag\n',text);
            end
            if nargin ==2
                v=pbag.items(text).getvalue;
            elseif nargin==3
                v=pbag.items(text).getvalue(wunit);
            end
        end
        
        function setvalue(pbag,text,v,wunit)  % get the value of this param
            if ~isKey(pbag.items,text)
                error('''%s'' is not a parameter in the parameter bag\n',text);
            end
            if nargin ==3
                setvalue(pbag.items(text),v);
            elseif nargin==4
                setvalue(pbag.items(text),v,wunit);
            end
        end
        
        function b=has_changed(pbag,pstr)
            if nargin==1 % the whole bag
                
                b=0;
                k=keys(pbag.items);
                for i=1:length(k)
                    bb=has_changed(pbag.items(k{i}));
                    if bb
                        b=1;
                        return;
                    end
                end
            elseif nargin==2 % just one entry
                p=pbag.items(pstr);
                b=has_changed(p);
                return;
            end
        end
        
        function set_changed_status(pbag,v)
            % set all members to value too
            k=keys(pbag.items);
            for i=1:length(k)
                set_changed_status(pbag.items(k{i}),v);
            end
        end
        
        function [maxtotalwidth,totalheight,maxtextwidth]=get_size(pbag,panel)
            % find out which text length is longest to align nicely at
            % midline
            k=keys(pbag.items);
            maxtextwidth=0;
            for i=1:length(pbag.items)
                si=get_text_size(pbag.items(k{i}),panel);
                maxtextwidth=max(maxtextwidth,si(1)); % see what is widest to find midline for alignment
            end
            % now see which element is the widest of all
            totalheight=0;
            
            max_left=0; % size is determined by how much goes to the left and right of the midline (where the text ends)
            max_right=0;
            for i=1:length(pbag.items)
                textsize=get_text_size(pbag.items(k{i}),panel);
                fullsize=get_draw_size(pbag.items(k{i}),panel);
                leftsize=textsize(1);
                rightsize=fullsize(1)-leftsize;
                max_left=max(max_left,leftsize);
                max_right=max(max_right,rightsize);
                totalheight=totalheight+fullsize(2); %
            end
            
            maxtotalwidth=max_left+max_right; % see what is widestto set window accordingly
        end
        
        function h=gui(pbag,mode,parent_panel) % put the gui on the screen (modal or not)
            x_edge_left=10; % how much edge to the left side
            x_edge_right=10; % how much edge to the right side
            y_edge_bottom=10; % how much edge at bottom
            
            
            if nargin<3
                % open a window
                pbag.guihandle=uifigure;
%                 pbag.guihandle.Scrollable='on';
                pbag.guihandle.MenuBar='none';
                pbag.guihandle.Resize='on';
                pbag.guihandle.Name=pbag.name;
                %             pbag.guihandle.CloseRequestFcn='@(f, event)my_closereq(f)';
                
                [maxtotalwidth,totalheight,maxtextwidth]=get_size(pbag,pbag.guihandle);
                
                maxtotalwidth=maxtotalwidth+x_edge_left+x_edge_right;
                totalheight=totalheight+y_edge_bottom;
                
                set(0,'units','pixel');
                screensize=get(0,'ScreenSize');
                pos=get(pbag.guihandle,'Position'); % resize figure
                pos(3)=maxtotalwidth+15;
                if totalheight+15<screensize(4)
                    pos(4)=totalheight+15;
                    pbag.guihandle.Scrollable='off';
                else
                    pos(4)=screensize(4);
                    pbag.guihandle.Scrollable='on';
                end
                pos(1)=screensize(3)-pos(3);
                pos(2)=screensize(4);
                set(pbag.guihandle,'Position',pos);
                parent_panel=pbag.guihandle;
                
            else
                pbag.guihandle=parent_panel;
                [~,~,maxtextwidth]=get_size(pbag,parent_panel);
            end
            
            if nargin<2
                mode='non-modal';
            end
            
            
            
            %% populate it
            y=y_edge_bottom;
            k=keys(pbag.items);
            for j=length(pbag.items):-1:1
                for i=1:length(pbag.items)
                    if pbag.items(k{i}).panelnr==j
                        sit=get_text_size(pbag.items(k{i}),parent_panel);
                        x=maxtextwidth-sit(1)+x_edge_left;
                        draw(pbag.items(k{i}),pbag.guihandle,x,y);
                        size=get_draw_size(pbag.items(k{i}),parent_panel);
                        y=y+size(2);
                    end
                end
            end
            h=pbag.guihandle;
            
            if isequal(mode,'modal')
                uiwait(h);
            end
        end
        
        function my_closereq(pbag,f)
            delete(f);
            pbag.guihandle=-1;
        end
        
        function ret= getparamsasstring(pbag,str)
            ret=[];nr=0;
            k=keys(pbag.items);
            for j=1:length(pbag.items)
                for i=1:length(pbag.items)
                    if pbag.items(k{i}).panelnr==j
                        nr=nr+1;
                        ret{nr}=getparamsasstring(pbag.items(k{i}),str);
                    end
                end
            end
        end
        
        function ret=get_param_value_string(pbag) % return lines like 'setvalue(obj,'what','what')
            ret=[];nr=0;
            k=keys(pbag.items);
            for j=1:length(pbag.items)
                for i=1:length(pbag.items)
                    if pbag.items(k{i}).panelnr==j
                        v=get_value_string(pbag.items(k{i}));
                        if ~isempty(v)
                            nr=nr+1;
                            ret{nr}=v;
                        end
                    end
                end
            end
        end
        
        function close_gui(pbag)
            delete(pbag.guihandle);
            pbag.guihandle=-1;
        end
    end
end
