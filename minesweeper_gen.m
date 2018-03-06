question = ('Please choose difficulty, Beginner (9x9, 10 bombs), Intermediate (16x16, 40 bombs), Expert (24x24, 99 bombs) or Custom\n');
choice = input(question, 's');
if strcmpi(choice, 'Beginner')
    X = 9; Y = 9;
    bombs = 10;
elseif strcmpi(choice, 'Intermediate')
    X = 16; Y = 16;
    bombs = 40;
elseif strcmpi(choice, 'Expert')
    X = 24; Y = 24;
    bombs = 99;
elseif strcmpi(choice, 'Custom')
    heightPrompt = 'Height\n'; widthPrompt = 'Width\n'; bombPrompt = 'Bombs\n';
    X = input(heightPrompt);
    Y = input (widthPrompt);
    bombs = input(bombPrompt);
end

load('statistics.mat');

endGame = 0;
mineTable = zeros(X,Y);
[height, width] = size(mineTable);
colPrompt = ('Chose a row\n');
rowPrompt = ('Unknown spaces are represented by 100 \n\nChose a column\n');
typePrompt = ('For a flag type "F", to click type "C" (Flags are represented by 70)\n');

mineOverlay = placeBombs(height, width, bombs, mineTable);
mineTable = placeOnMap(mineTable, mineOverlay);
mineTable = numSet(mineTable, height, width);
clear count; clear mineOverlay; clear bombPromt; clear heightPrompt; clear question; clear widthPrompt;

gameMap = zeros(X, Y);
for n = 1:X
    for m = 1:Y
        gameMap(n,m) = 'd';
    end
end
[gameMap, gamesWon, gamesLost, gameTime, winStreak] = gamePlay(mineTable, gameMap, rowPrompt, colPrompt, typePrompt, height, width, bombs, gamesWon, gamesLost, winStreak);
disp(gameMap)
allTimes = [allTimes, gameTime];

bestTime = min(allTimes);
avgTime = sum(allTimes)/numel(allTimes);
totalGames = gamesWon + gamesLost;
percentWin = (gamesWon / totalGames) * 100;
percentLoss = (gamesLost / totalGames) * 100;

save('statistics.mat', 'gamesWon', 'gamesLost', 'allTimes', 'winStreak');


function mineOverlay = placeBombs(height, width, bombs, mineTable)
mineOverlay = mineTable;
count = 0;
while count < bombs
    row = randi([1, height]);
    col = randi([1, width]);
    if mineOverlay(row, col) ~= 9
        mineOverlay(row,col) = 9; %9 = bomb
        count = count + 1;
    end
end
end

function mineTable = placeOnMap(mineTable, mineOverlay)
[heightOver, widthOver] = size(mineOverlay);
for n = 1:heightOver
    for m = 1:widthOver
        mineTable(n,m) = mineOverlay(n,m);
    end
end
end

function mineTable = numSet(mineTable, height, width)
for n = 1:height
    for m = 1:width
        if mineTable(n, m) == 9
            for row = n-1:n+1
                for col = m-1:m+1
                    if row >= 1 && row <= height && col >= 1 && col <= width && mineTable(row, col) ~= 9
                        mineTable(row, col) = mineTable(row, col) + 1;
                    end
                end
            end
        end
    end
end
end

function gameMap = openSpots(row, col, mineTable, gameMap, height, width)
gameMap(col, row) = mineTable(col, row);
for n = 1:height
    for m = 1:width
        for Row = n-1:n+1
            for Col = m-1:m+1
                if Row >= 1 && Row <= height && Col >= 1 && Col <= width && mineTable(Col, Row) ~= 9
                    if gameMap(m, n) == 0
                        gameMap(Col, Row) = mineTable(Col, Row);
                    end
                end
            end
        end
    end
end
for n = height:-1:1
    for m = width:-1:1
        for Row = n-1:n+1
            for Col = m-1:m+1
                if Row >= 1 && Row <= height && Col >= 1 && Col <= width && mineTable(Col, Row) ~= 9
                    if gameMap(m, n) == 0
                        gameMap(Col, Row) = mineTable(Col, Row);
                    end
                end
            end
        end
    end
end
end


function [gameMap, gamesWon, gamesLost, gameTime, winStreak] = gamePlay(mineTable, gameMap, rowPrompt, colPrompt, typePrompt, height, width, bombs, gamesWon, gamesLost, winStreak)
endGame = 0;
tic;
while endGame < bombs && endGame >= 0
    disp(gameMap)
    row = input(rowPrompt);
    col = input(colPrompt);
    type = input(typePrompt, 's');
    endGame = 0;
    if row <= height && col <= width
        if strcmpi(type, 'F')
            if gameMap(col, row) ~= 'F'
                gameMap(col, row) = 'F';
            else
                gameMap(col, row) = 'd';
            end
        else
            if mineTable(col, row) == 9
                for n = 1:height
                    for m = 1:width
                        if mineTable(m,n) == 9
                            gameMap(m,n) = mineTable(m,n);
                        end
                    end
                end
                endGame = -1;
            elseif mineTable(col, row) == 0
                gameMap = openSpots(row, col, mineTable, gameMap, height, width);
            else
                gameMap(col, row) = mineTable(col, row);
            end
        end
        if endGame < bombs && endGame >= 0
            endGame = 0;
            for n = 1:height
                for m = 1:width
                    if gameMap(m, n) == 70 && mineTable(m, n) == 9
                        endGame = endGame + 1;
                    elseif gameMap(m, n) == 70 && mineTable(m, n) ~=9
                        endGame = endGame - 1;
                    end
                end
            end
        end
    end
end
if endGame == bombs
    gamesWon = gamesWon + 1;
    disp('You Win')
    winStreak = winStreak + 1;
elseif endGame < 0
    gamesLost = gamesLost + 1;
    disp('You Lose')
    winStreak = 0;
end
gameTime = toc;

end