% GENERALIZED FUNTION APPROXIMATION BY FEATURES

% Fit (t1, t2, t3, t4) --> (a list of products of cos and sin of the ti's)

k = 1000; % #of discrete domain points

t1 = zeros(k,1);
t2 = zeros(k,1);
t3 = zeros(k,1);
t4 = zeros(k,1);

t11 = zeros(k,1); 
t12 = zeros(k,1); 
t21 = zeros(k,1); 
t22 = zeros(k,1); 
t31 = zeros(k,1); 
t32 = zeros(k,1); 
t41 = zeros(k,1); 
t42 = zeros(k,1); 

% create all the necessary sum variables:
s1 = zeros(k,1); s2 = zeros(k,1); s3 = zeros(k,1); s4 = zeros(k,1);
% at worst, we have 43 combos for all 11 features

f1 = zeros(k,1);
f2 = zeros(k,1);
f3 = zeros(k,1);
f4 = zeros(k,1);
f5 = zeros(k,1);
f6 = zeros(k,1);
f7 = zeros(k,1);
f8 = zeros(k,1);
f9 = zeros(k,1);
f10 = zeros(k,1);
f11 = zeros(k,1);

lower_lim = -pi; % set as desired
upper_lim = pi;


for i=1:k
    
   t1(i) = lower_lim + (upper_lim-lower_lim)*(i-1)/(k-1);% the linspace
   t2(i) = t1(i);
   t3(i) = t1(i);
   t4(i) = t1(i);
   
end
% Creating "real" theta data: randomly shuffle the arrays:
p1 = randperm(k); p2 = randperm(k); p3 = randperm(k); p4 = randperm(k);
t1 = t1(p1); t2 = t2(p2); t3 = t3(p3); t4 = t4(p4);

% FEATURES
for i=1:k
   % pure cos/sin not really useful 
   t11(i) = sin(t1(i));
   t12(i) = cos(t1(i));
   t21(i) = sin(t2(i));
   t22(i) = cos(t2(i));
   t31(i) = sin(t3(i));
   t32(i) = cos(t3(i));
   t41(i) = sin(t4(i));
   t42(i) = cos(t4(i));
   
   s1(i) = sin(t1(i) + t2(i) - t4(i));
   s2(i) = sin(t1(i) - t2(i) + t4(i));
   s3(i) = sin(t1(i) + t2(i) + t4(i));
   s4(i) = sin(t1(i) - t2(i) - t4(i));
   
end

% TARGETS
for i=1:k
   f1(i) = sin(t4(i))*sin(t1(i))*sin(t3(i));
   f2(i) = sin(t4(i))*cos(t1(i))*cos(t3(i))*sin(t2(i));
   f3(i) = cos(t1(i))*cos(t2(i))*cos(t4(i));
   f4(i) = cos(t1(i))*cos(t2(i));
   f5(i) = cos(t4(i))*sin(t2(i));
   f6(i) = cos(t2(i))*cos(t3(i))*sin(t4(i));
   f7(i) = sin(t2(i));
   f8(i) = sin(t4(i))*cos(t1(i))*sin(t3(i));
   f9(i) = sin(t4(i))*cos(t3(i))*sin(t1(i))*sin(t2(i));
   f10(i) = cos(t2(i))*cos(t4(i))*sin(t1(i));
   f11(i) = cos(t2(i))*sin(t1(i));
end

% Optimization Routine below

X = [s1, s2, s3, s4]';
Y = [f10]';

T = k;
m = size(Y,1);
n = size(X,1);

cvx_begin
    variable W0(m,n)
    minimize norm(Y - W0*X, Inf)
cvx_end

avg_error = 0;
for i=1:T
    d = norm(Y(:,i)-W0*X(:,i),2);
    avg_error = avg_error + d;
    %if (d > 0.6)
    %    d
    %    i
    %end
end
avg_error = avg_error/T

% SECOND TEST - using CVX approx of 1-layer NN

X = [t1, t2, t3, t4]';
Y = [f2]'; % product of 4 sin/cos terms --> product of 8 cos (via identity)

T = k;
m = size(Y,1);
n = size(X,1);

cvx_begin
    variable W0(m,n)
    variable W1(m,m)
    variable s(m) 
    variables z(m) z2(m) z4(m) z8(m) 
    
    minimize norm(Y - s, 2)
    subject to
    
        z == W0*X;
        z2 >= diag(z)*z;
        z4 >= diag(z2)*z2;
        z8 >= diag(z4)*z4;
        % COSINE TIME
        % W = 1.0000    0.0000   -0.5000    0.0417   -0.0014    0.0000   -0.0000    0.0000
        % note: need *convex* approximation (had to omit some above terms
        % to make it work)
        
        ones(m,1) - 0.5*z4 -0.0014*z8 <= s;
        
        
        
cvx_end


