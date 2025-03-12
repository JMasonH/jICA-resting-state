function X_i = interp_pts(X,bad_pts,PLOT)
% interpolate over bad points; all rows in X
% (assumes time series are along the rows)
% calls interp_ts

for jj=1:size(X,1)
    if (PLOT); clf; end;
    y_int = interp_ts(X(jj,:),bad_pts,PLOT);
    if (PLOT); pause; end;
    X_i(jj,:) = y_int;
end





