function X_fixed = fixends(X,k);
% for each row in X, set the first "k" points to the median of the
% k-to-k+5 points. Same with the end.

B1 = repmat(median(X(:,k:k+5),2),1,k-1);
BN = repmat(median(X(:,end-k-5:end-k),2),1,k);
X_fixed = X;
X_fixed(:,1:k-1) = B1;
X_fixed(:,end-k+1:end) = BN;


