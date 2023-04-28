function Value =  ReadTime(imagen2)  

if size(imagen2,3)==3 %RGB image
    imagen2=rgb2gray(imagen2);
end
% Convert to BW
imagen = imagen2(24:32,29:129);
% imagen = imagen2(24:32,141:147);
threshold = graythresh(imagen);
imagen =~im2bw(imagen,threshold);
% Remove all object containing fewer than 30 pixels
imagen = bwareaopen(imagen,2);
imagen = ~imagen;
% imagesc(imagen, 'Parent', currAxes);

% zero = imagen(:,3:8);
% figure(2)
% image(zero)


%Storage matrix word from image
word=[ ];
re=imagen;
%Opens text.txt as file for write
% fid = fopen('text.txt', 'wt');
% Load templates
load templates
global templates
% Compute the number of letters in template file
num_letras=size(templates,2);
while 1
    %Fcn 'lines' separate lines in text
    [fl re]=lines(re);
    imgn=fl;
    %Uncomment line below to see lines one by one
%     imshow(fl);pause(0.5)    
    %-----------------------------------------------------------------     
    % Label and count connected components
    [L Ne] = bwlabel(imgn);    
    for n=1:Ne
        [r,c] = find(L==n);
        % Extract letter
        n1=imgn(min(r):max(r),min(c):max(c));  
        % Resize letter (same size of template)
        img_r=imresize(n1,[9 7]);
        %Uncomment line below to see letters one by one
         %imshow(img_r);pause(0.5)
        %-------------------------------------------------------------------
        % Call fcn to convert image to text
        letter=read_letter(img_r,num_letras);
        
%          figure(2)
%          image(img_r);
        
        % Letter concatenation
        word=[word letter];
    end
    %fprintf(fid,'%s\n',lower(word));%Write 'word' in text file (lower)
    
  %BUG possible: if zour Video doesn't have the appropriate time stamps  
    if length(word)~=9    
        if ~any(imagen(:,4))
            word=['0',word];
        end
        if ~any(imagen(:,27))
            word=[word(1:2),'0',word(3:end)];
        end
        if ~any(imagen(:,51))
            word=[word(1:4),'0',word(5:end)];
        end
        if ~any(imagen(:,76))
            word=[word(1:6),'0',word(7:end)];
        end
        if ~any(imagen(:,83))
            word=[word(1:7),'0',word(8)];
        end
    end
    
    
    
    
%     fprintf(fid,'%s\n',word);%Write 'word' in text file (upper)
    % Clear 'word' variable
    Value = word;
    %*When the sentences finish, breaks the loop
    if isempty(re)  %See variable 're' in Fcn 'lines'
        break
    end    
end


% fclose(fid);
% %Open 'text.txt' file
% system(['open text.txt']);
% fprintf('For more information, visit: <a href= "http://www.matpic.com">www.matpic.com </a> \n')
% clear all   
         
         
        
        % Read video frames until available
%         while hasFrame(vidObj)
%             vidFrame = readFrame(vidObj);
%             image(vidFrame, 'Parent', currAxes);
%             currAxes.Visible = 'off';
%             pause(1/vidObj.FrameRate);
%         end