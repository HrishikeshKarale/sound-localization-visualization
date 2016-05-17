tic
format shortg;
left_id= 3;
right_id= 2;
back_id= 4;
samplingrate= 48000;
nofchannels= 1;
bitrate= 24;
inputstate= 1;
% no of times threshold is calculated
outerloop= 10;
totalinner=40;
% indicated no of seconds the microphones would record data for the calculated threshold value. 10 seconds in this case.
innerloop= totalinner;
% time for which threshold is calculated
n= 2;
% divide no of seconds into parts 0.25 sec each
div= 4;
outersegmentation= 9600;
innersegmentation= 4800;
% print file statements
leftstr= '{"direction":"LEFT"},';
rightstr= '{"direction":"RIGHT"},';
backstr= '{"direction":"BACK"},';
startstr= '{"Tablename":[';
endstr= ']}';
% check for availability of threshold
thresholdNotAvailable= true;


% stores info about input devices connected to the laptop/computer
%LinkForTheFunctionUsed:http://www.mathworks.com/help/matlab/ref/audiodevinfo.html#bt6f5yd-1
left= audiodevinfo(inputstate, left_id);
% initialize microphones
%linkForTheFunctionUsed:http://www.mathworks.com/help/matlab/ref/audiorecorder.html
leftrecorder= audiorecorder(samplingrate, bitrate, nofchannels, left_id);

right= audiodevinfo(inputstate, right_id);
rightrecorder= audiorecorder(samplingrate, bitrate, nofchannels, right_id);

back= audiodevinfo(inputstate, back_id);
backrecorder= audiorecorder(samplingrate, bitrate, nofchannels, back_id);

% this loop is responsible for calculating new threshold every (b*2) seconds
while outerloop>0
    
    outerloop= outerloop- 1;

    % record audio for n seconds for calculating threshold
    record(leftrecorder, n);
    record(rightrecorder, n);
    record(backrecorder, n);
    
    % pause for n seconds for record function to end
    %LinkForTheFunctionUsed:http://www.mathworks.com/help/matlab/ref/pause.html
    pause(n);
    
    % stores an array of audio data values
    %linkForTheFunctionDescription:http://www.mathworks.com/help/matlab/ref/audiorecorder.getaudiodata.html?requestedDomain=www.mathworks.com
    leftdata= getaudiodata(leftrecorder);
    rightdata= getaudiodata(rightrecorder);
    backdata= getaudiodata(backrecorder);
    
    % visualization window
    %LinkForTheFunctionUsed:http://www.mathworks.com/help/matlab/ref/figure.html?searchHighlight=figure
    figure(1);
    
    % gives plot co-ordinates in the window to display graph
    %LinkForTheFunctionUsed:http://www.mathworks.com/help/matlab/ref/subplot.html?searchHighlight=subplot
    subplot(4, 3, 1);
    
    % draw a graph in the above assigned grid location
    %LinkForTheFunctionUsed:http://www.mathworks.com/help/matlab/ref/plot.html?searchHighlight=plot
    plot(leftdata);
    
    % set title to the above graph
    title ('Threshold Calculation: Left Microphone');
    
    
    subplot(4, 3, 2);
    plot(rightdata);
    title ('Threshold Calculation: Right Microphone');
    
    subplot(4, 3, 3);
    plot(backdata);
    title ('Threshold Calculation: Back Microphone');
    
    % calculate size of data recorded
    leftsize= size(leftdata);
    rightsize= size(rightdata);
    backsize= size(backdata);
    
    % initialize individual microphone threshold to zero
    threshold_left= 0.0;
    threshold_right= 0.0;
    threshold_back= 0.0;
    
    % calculate ndividual microphone threshold
    looplimit=uint8(min([leftsize rightsize backsize])/outersegmentation);
    for i= 0:(looplimit-1)
        temp1= max(leftdata(((i*outersegmentation)+1):((i+1)*outersegmentation)));
        threshold_left=threshold_left+temp1;
        temp2= max(rightdata(((i*outersegmentation)+1):((i+1)*outersegmentation)));
        threshold_right=threshold_right+temp2;
        temp3= max(backdata(((i*outersegmentation)+1):((i+1)*outersegmentation)));
        threshold_back=threshold_back+temp3;
    end
    threshold_left= threshold_left+ max(leftdata(((9*outersegmentation)+1):end));
    threshold_right= threshold_right+ max(rightdata(((9*outersegmentation)+1):end));
    threshold_back= threshold_back+ max(backdata(((9*outersegmentation)+1):end));
    
    threshold_left= threshold_left/10; 
    threshold_right= threshold_right/10;
    threshold_back= threshold_back/10;
    
    % calculate threshold
    threshold= max([threshold_left threshold_right threshold_back]);
    
    % attach an appropriate buffer of  to threshold
    buffered_threshold= 1.5* threshold;
    
    % display calculated threshold value
    display(threshold);
    display(buffered_threshold);
    
    innerloop= totalinner;
     
    
    
    
%    fid= fopen('E:/script1.json', 'A');
%    fprintf(fid, '%s\r\n', startstr);
    
    
    
    % Records audio data and processes it.
    while(innerloop>0)
        innerloop= innerloop- 1;
    
        % record audio data for processing in bursts of 0.5 seconds
        record(leftrecorder, n/div);
        record(rightrecorder, n/div);
        recordblocking(backrecorder, n/div);
        
        % converts recieved audio signal into array of values for processing
        leftdata= getaudiodata(leftrecorder);
        rightdata= getaudiodata(rightrecorder);
        backdata= getaudiodata(backrecorder);

        %left microphone plotting
           subplot(4, 3, [4 6]);
           plot(leftdata);
           
           title('LEFT Microphone Reading');
           axis auto;
        
            % helps with drawing multiple layers of graph on a single plot
            %LinkForTheFunction/used:http://www.mathworks.com/help/matlab/ref/hold.html?searchHighlight=hold%20on
           hold on;

                % equation for distinguishing values above threshold
               idx= (leftdata>buffered_threshold);

                % plot the new data in red color
               plot(leftdata(idx), 'r')

                % draw a line to indicate threshold limit
               hline= refline([0 buffered_threshold]);

                % color line red
               hline.Color= 'r';

           hold off;

        %right microphone data plotting
           subplot(4, 3, [7 9]);
           plot(rightdata);
           title('RIGHT Microphone Reading');
           axis auto;
           hold on;
               idx= (rightdata>=buffered_threshold);
               plot(rightdata(idx), 'g');
               hline= refline([0 buffered_threshold]);
               hline.Color= 'g';
           hold off;

        %back microphone data plotting
           subplot(4, 3, [10 12]);
           plot(backdata);
           title('BACK Microphone Reading');
           axis auto;
           hold on;
               idx= (backdata>=buffered_threshold);
               plot(backdata(idx), 'm');
               hline= refline([0 buffered_threshold]);
               hline.Color= 'm';
           hold off;

        % calculate size of array for running loops on audio data collected
        leftsize= size(leftdata);
        rightsize= size(rightdata);
        backsize= size(backdata);
        
        sizee= min([leftsize rightsize backsize]);
        

        
        
        
        
        
        
        innerlooplimit= min([leftsize rightsize backsize])/innersegmentation;
        for i= 0:(innerlooplimit-1)
            max_left= max(leftdata(((i*innersegmentation)+1):((i+1)*innersegmentation)));
            max_right= max(rightdata(((i*innersegmentation)+1):((i+1)*innersegmentation)));
            max_back= max(backdata(((i*innersegmentation)+1):((i+1)*innersegmentation)));
            temp= max([max_left max_right max_back]);
            if temp> buffered_threshold
                if max_right==temp
                    if max_left>buffered_threshold && max_back>buffered_threshold
%                        fprintf(fid,'%s\r\n', rightstr);
                        display('RIGHT found');
                        x.direction = 'RIGHT';
                    end
                elseif max_left==temp
                    if max_right>buffered_threshold && max_back>buffered_threshold
%                        fprintf(fid, '%s\r\n', leftstr);
                        display('LEFT found');
                        x.direction = 'LEFT';
                    end
                elseif max_right>buffered_threshold && max_left>buffered_threshold
%                        fprintf(fid, '%s\r\n', backstr);
                    display('BACK found');
                    x.direction = 'BACK';
                end
            end
        end
                
        max_left= max(leftdata(((innerlooplimit*innersegmentation)+1):end));
        max_right= max(rightdata(((innerlooplimit*innersegmentation)+1):end));
        max_back= max(backdata(((innerlooplimit*innersegmentation)+1):end));
        temp= max([max_left max_right max_back]);
        if temp> buffered_threshold
            if max_right==temp
                if max_left>buffered_threshold && max_back>buffered_threshold
%                    fprintf(fid, '%s\r\n', rightstr);
                   display('RIGHT found');
                   x.direction = 'RIGHT';
                end
            elseif max_left==temp
                if max_right>buffered_threshold && max_back>buffered_threshold
%                    fprintf(fid, '%s\r\n', leftstr);
                     display('LEFT found');
                     x.direction = 'LEFT';
                end
            elseif max_right>buffered_threshold && max_left>buffered_threshold
%                fprintf(fid, '%s\r\n', backstr);
                 display('BACK found');
                 x.direction = 'BACK';
            end
        end
        savejson('',x,'C:\Users\tanmaypc\Documents\722\sound-localization-visualization\data\matlabData.json');
    end
%    fprintf(fid, '%s\r\n\n\n', endstr);
%    fclose(fid);
        
end
toc
%system(['notepad ' 'E:/script1.json'])