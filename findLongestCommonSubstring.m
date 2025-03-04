
function commonStr = findLongestCommonSubstring(str1, str2)
    len1 = length(str1);
    len2 = length(str2);
    longestLen = 0;
    commonStr = '';
    
    % Initialize a matrix to store lengths of longest common suffixes
    lcsuff = zeros(len1, len2);
    
    for i = 1:len1
        for j = 1:len2
            if str1(i) == str2(j)
                if i == 1 || j == 1
                    lcsuff(i, j) = 1;
                else
                    lcsuff(i, j) = lcsuff(i-1, j-1) + 1;
                end
                
                if lcsuff(i, j) > longestLen
                    longestLen = lcsuff(i, j);
                    commonStr = str1(i-longestLen+1:i);
                end
            else
                lcsuff(i, j) = 0;
            end
        end
    end
end