%   Copyright 2019 Stefan Bleeck, University of Southampton
%   Author: Stefan Bleeck (bleeck@gmail.com)


function save_excel(A,filename,fieldcodes)
%save the struct A to filename

if nargin<3
    fieldcodes=1;
end

%first line: field codes
b=fields(A{1});
nr_fields=length(b);
B=[];

if fieldcodes
    for i=1:nr_fields
        B{1,i}=b{i};
    end
end

for i=1:length(A)
    a=struct2cell(A{i});
    for j=1:nr_fields
        cont=a{j}; % eliminate NaNs
        if isnan(cont)
            cont='';
        end
        if isnumeric(cont)
            cont=num2str(cont);
        end
        %eliminate commas
        cont=regexprep(cont,',',';');
        % trim
        cont=strtrim(cont);
        
        B{i+fieldcodes,j}=cont;
    end
end

%xlswrite(filename,B);  % will not work on MAC :(

%csvwrite(filename,B);
cell2csv(filename,B,',')

