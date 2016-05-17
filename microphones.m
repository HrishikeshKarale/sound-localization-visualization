tic
format shortg;
% stores info about input devices connected to the laptop/computer
% LinkForTheFunctionUsed:http://www.mathworks.com/help/matlab/ref/audiodevinfo.html#bt6f5yd-1
left= audiodevinfo(1, 2);
back= audiodevinfo(1, 3);
right= audiodevinfo(1, 1);
% initialize microphones
% linkForTheFunctionUsed:http://www.mathworks.com/help/matlab/ref/audiorecorder.html
leftrecorder= audiorecorder(32000, 24, 1, 2);
rightrecorder= audiorecorder(32000, 24, 1, 3);
backrecorder= audiorecorder(32000, 24, 1, 4);
% no of times threshold is calculated
a= 10;
% this loop is responsible for calculating new threshold every (b*2) seconds
while a>0
    a= a- 1;
    % time for which threshold is calculated
    n= 2;
    % record audio for n seconds for calculating threshold
    record(leftrecorder, n);
    record(rightrecorder, n);
    record(backrecorder, n);
    % pause for n seconds for record function to end
    % LinkForTheFunctionUsed:http://www.mathworks.com/help/matlab/ref/pause.html
    pause(n);
    % stores an array of audio data values
    % linkForTheFunctionDescription:http://www.mathworks.com/help/matlab/ref/audiorecorder.getaudiodata.html?requestedDomain=www.mathworks.com
    leftdata= getaudiodata(leftrecorder);
    rightdata= getaudiodata(rightrecorder);
    backdata= getaudiodata(backrecorder);
    % visualization window
    % LinkForTheFunctionUsed:http://www.mathworks.com/help/matlab/ref/figure.html?searchHighlight=figure
    figure(1);
    % gives plot co-ordinates in the window to display graph
    % LinkForTheFunctionUsed:http://www.mathworks.com/help/matlab/ref/subplot.html?searchHighlight=subplot
    %subplot(4, 3, 1);
    % draw a graph in the above assigned grid location
    % LinkForTheFunctionUsed:http://www.mathworks.com/help/matlab/ref/plot.html?searchHighlight=plot
    %plot(leftdata);
    % set title to the above graph
    title ('Threshold Calculation: Left Microphone');
    %subplot(4, 3, 2);
    %plot(rightdata);
    title ('Threshold Calculation: Right Microphone');
    %subplot(4, 3, 3);
    %plot(backdata);
    title ('Threshold Calculation: Back Microphone');
    % calculate threshold
    leftthreshold= mean(abs(leftdata));
    rightthreshold= mean(abs(rightdata));
    backthreshold= mean(abs(backdata));
    threshold= (leftthreshold+rightthreshold+backthreshold)/3;
    % display calculated threshold value
    display(threshold);
    leftsize= size(leftdata);
    rightsize= size(rightdata);
    backsize= size(backdata);
    % indicated no of seconds the microphones would record data for the calculated threshold value. 10 seconds in this case.
    b= 20;
    % Records audio data and processes it.
    while(b>0)
        b= b- 1;
        % record audio data for processing in bursts of 0.5 seconds
        record(leftrecorder, n/4);
        record(rightrecorder, n/4);
        record(backrecorder, n/4);
        pause(n/4);
        % converts recieved audi osignal into array of values for processing
        leftdata= getaudiodata(leftrecorder);
        rightdata= getaudiodata(rightrecorder);
        backdata= getaudiodata(backrecorder);
        %subplot(4, 3, [4 6]);
        %plot(leftdata);
        title('Left Microphone Reading');
        % helps with drawing multiple layers of graph on a single plot
        % LinkForTheFunction/used:http://www.mathworks.com/help/matlab/ref/hold.html?searchHighlight=hold%20on
        hold on;
        % equation for distinguishing values above threshold
        idx= (leftdata>threshold);
        % plot the new data in red color
        %plot(leftdata(idx), 'r.')
        % draw a line to indicate threshold limit
        hline= refline([0 threshold]);
        % color line red
        hline.Color= 'r';
        hold off;
        %subplot(4, 3, [7 9]);
        %plot(rightdata);
        hold on;
        idx= (rightdata>threshold);
        %plot(rightdata(idx), 'g.');
        hline= refline([0 threshold]);
        hline.Color= 'g';
        hold off;
        title('Back Microphone Reading');
        %subplot(4, 3, [10 12]);
        %plot(backdata);
        hold on;
        idx= (backdata>threshold);
        %plot(backdata(idx), 'm.');
        hline= refline([0 threshold]);
        hline.Color= 'm';
        hold off;
        title('Right Microphone Reading');
        % calculate size of array for running loops on audio data collected
        leftsize= size(leftdata);
        rightsize= size(rightdata);
        backsize= size(backdata);
        sizee= min([leftsize rightsize backsize]);
        % display the microphone name that breaks threshold  wth higher values when compared toother microphones.
        for i= 1:sizee
            if (rightdata(i)>threshold || leftdata(i)>threshold || backdata(i)>threshold)
                temp= max([leftdata(i) rightdata(i) backdata(i)]);
                if rightdata(i)==temp
                    display('RIGHT found');
                    x.direction = 'RIGHT';
                elseif leftdata(i)==temp
                    display ('LEFT found');
                    x.direction = 'LEFT';
                else
                    display ('BACK FOUND');
                    x.direction = 'BACK';
                end
            end
            savejson('',x,'C:\Users\tanmaypc\Documents\matlab-mean-demo\data\matlabData.json');
        end
    end
end
toc